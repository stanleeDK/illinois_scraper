require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'mysql2'
require 'date'

# http://chicagotribune.public-record.com/realestate/

# GLOBAL VARIABLES 
city 			= "Cook" 		# county to scrape - get full list here: http://chicagotribune.public-record.com/realestate/
pageCount 		= 2345 			# The last page number of the county you want to scrape - must be greater than 2
start 			= '10/19/2016'  # start date to look for recent sales
enddate 		= '4/19/2017'	# end date to look for recent sales 

# application kicks off at the bottom, this is a function that write to the db 

def saveData (res,cityP,clientP)
	doc 	= Nokogiri::HTML(res.body)
	table 	= doc.xpath("//table[2]")
	rows1 	= table.xpath("//table[2]/tr")

	fileName = "chicagotribune output" + cityP + "1.html" # debug file 
	open(fileName, 'a') { |f|
		 	# f.puts res3.body
		 	# f.puts table
		 	# f.puts "-------------"
	
		 	rows1.each do |r|
		 		
		 		f.puts r.inner_html
				# <td class="">$261,000.00<br>
				# 2661 MALMAISON , BELVIDERE, 61008-7417<em><br>
				# JAMES S FALCO sold to EARL R SHUMAKER</em>
				# </td>
				# <td align="right" class="">04/04/17<br>
				# <div id="28542-boone"><a href="javascript:%20addToCart('2661+MALMAISON+%2C+BELVIDERE%2C+61008%2D7417',28542,'boone',%20're')">Add to Cart</a></div>
				# </td>
				# $261,000.00
				# 2661 MALMAISON , BELVIDERE, 61008-7417
				# EARL R SHUMAKER

		 		cells = r.xpath('td')
		 		if cells.length > 0 
			 		
			 		# debug code - parse each <td> cell 
		 			# cells.each do |c|
		 			# 	f.puts "#{cells.inner_html}" 
		 			# 	# f.puts cells.inner_html
		 			# end 
		 			# f.puts "0 #{cells[0].inner_html}"
		 			# f.puts "1 #{cells[1].inner_html}"
		 			# f.puts "2 #{cells[2].inner_html}"

		 			# parse out this code to get value, address and name
					# <td class="">$261,000.00<br>
					# 2661 MALMAISON , BELVIDERE, 61008-7417<em><br>
					# JAMES S FALCO sold to EARL R SHUMAKER</em>
					# </td>
		 			val_add_name = cells[1].inner_html.split("<br>")
		 			# f.puts val_add_name[0]
		 			# f.puts val_add_name[1]
		 			# f.puts val_add_name[2]

		 			sold_at = cells[2].inner_html.split("<br>")[0]


		 			value 			= val_add_name[0].delete("\n").gsub(/[^\d\.]/, '').to_f
		 			full_address 	= val_add_name[1].delete("<em>").delete("\n")
		 			soldto 			= val_add_name[2].to_s.split(" sold to ")[1].to_s.delete("\r").delete("<em>").delete("/")

		 			# street_address format: 2661 MALMAISON , BELVIDERE, 61008-7417
		 			temp_street_address = full_address.split(",")
		 			street_address 		= temp_street_address[0].to_s.strip
		 			city 				= temp_street_address[1].to_s.strip
		 			zip 				= temp_street_address[2].to_s.strip
		 			
		 			f.puts value
		 			f.puts full_address
		 			f.puts street_address
		 			f.puts city
		 			f.puts zip
		 			f.puts soldto
		 			f.puts sold_at
			 		# f.puts "INSERT INTO " + cityP + "(sold_to,sold_by,street_address,city,zip,value,sold_at) VALUES ('" + soldto.to_s + "','" + soldby.to_s.strip + "','" + street_address.to_s + "','" +  city + "','" +  zip + "','" + value.to_s + "','" + sold_at + "')"
			 		f.puts "-----"

			 		# clientP.query("INSERT INTO #{cityP} (sold_to,street_address,city,zip,value,sold_at) VALUES (' #{soldto}',' #{street_address}',' #{city}','#{zip}',#{value},'#{sold_at.to_s}')")

		 		end 
		 		
				# r.xpath('td').each_with_index do |td,j|
				# 	f.puts td.text + "---" + td.text.length.to_s
				# end 
		 	end 
	}
end 



client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :database => "chicagotribune", :password => "")

client.query("DROP TABLE IF EXISTS `"+ city + "`;")
client.query("CREATE TABLE " +  city +  " (sold_to TEXT, street_address TEXT, city TEXT, zip TEXT, value DECIMAL(10,2), sold_at TEXT)")

uri 		= URI ("http://chicagotribune.public-record.com/realestate/search/" + city.to_s)
response 	= Net::HTTP.post_form(uri, 'lck' 	 => 'unlocked',
									'lck_2'	 => 'unlocked',
									'sdate'	 => start,
									'edate'	 => enddate,
									'radio1' => 'city',
									'radio2' => 'range',
									'submit' => 'Start Searching Now'
								)

puts uri.to_s

case response 
when Net::HTTPRedirection then 
	
	location 		= response['location']
	location 		= URI.parse("http://chicagotribune.public-record.com" + location.to_s)
	
	http 			= Net::HTTP.new(location.host,location.port)
	req 			= Net::HTTP::Get.new(location.request_uri)
	req['Cookie'] 	= response['set-cookie'].to_s
	
	res 			= http.request(req)

	puts res.code;
	puts location
	
	case res 
	when Net::HTTPRedirection then 

		location2 		= res['location']	
		location2 		= URI.parse("http://chicagotribune.public-record.com" + location2.to_s)
		http2 			= Net::HTTP.new(location2.host,location2.port)
		req2 			= Net::HTTP::Get.new(location2.request_uri)
		req2['Cookie'] 	= response['set-cookie'].to_s
		
		res3 			= http.request(req2)

		puts res3.code
		puts location2 
		# puts res3.body
		# saveData(res3,city,client)

		# fileName = "chicagotribune output" + city + "1.html"
		# open(fileName, 'w') { |f|
 	# 		 f.puts res3.body
		# }

		pageCounter 	= "2"

		for i in 1..pageCount #2847
			pageCounter=i

			nextloc 		= URI.parse("http://chicagotribune.public-record.com/realestate/results/" + pageCounter.to_s + "/date:desc")
			http3 			= Net::HTTP.new(nextloc.host,nextloc.port)
			req3 			= Net::HTTP::Get.new(nextloc.request_uri)
			req3['Cookie'] 	= response['set-cookie'].to_s
			res9 			= http3.request(req3)

			# puts "#{pageCounter} pagecounter" 
			puts res9.code
			puts nextloc

			
			saveData(res9,city,client)

			pageCounter = pageCounter.succ 
			# puts pageCounter
		end 
		puts "done" 
	end 
end 



