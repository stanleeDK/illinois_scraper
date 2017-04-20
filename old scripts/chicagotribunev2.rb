require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'mysql2'

# http://chicagotribune.public-record.com/realestate/results/817/date:desc
# THIS IS THE LAST PAGE THAT WAS SCRAPED

def saveData (res,cityP,clientP)
	doc 	= Nokogiri::HTML(res.body)
	table 	= doc.xpath("//table[2]")
	rows1 	= table.xpath("//table[2]/tr")

	fileName = "chicagotribune output" + cityP + "1.html"
	open(fileName, 'a') { |f|
		 	# f.puts res3.body
		 	# f.puts table
		 	# f.puts "-------------"
	
		 	rows1.each do |r|
		 		# f.puts r.inner_html
		 		cells = r.xpath('td')
		 		if cells.length > 0 
			 		

			 		# f.puts cells[0].text
			 		f.puts "----"
			 		
			 		# f.puts cells[1].inner_html 
			 		value = cells[1].inner_html.split("<br>")[0]
			 		f.puts value
			 		
			 		f.puts cells[1].inner_html;
			 		tempAddress = cells[1].inner_html.split("</span>")[1].split("<br>")[0].split("<em>")[0].split(",")
			 		
			 		street_address = tempAddress[0]
			 		city = tempAddress[1].strip
			 		zip = tempAddress[2].strip

			 		f.puts tempAddress[0]
			 		f.puts tempAddress[1].strip
			 		f.puts tempAddress[2].strip


			 		soldto = cells[1].xpath("em").text.split(" sold to ")[1]
			 		soldby = cells[1].xpath("em").text.split(" sold to ")[0]

			 		# soldto = cells[1].xpath("em")
			 		f.puts "sold to: " + soldto.to_s
			 		f.puts "sold by: " + soldby.to_s.strip
			 		f.puts "----"

			 		sold_at = cells[2].text.split("\n")[0].to_s.strip #date 

			 		f.puts sold_at

			 		f.puts "INSERT INTO " + cityP + "(sold_to,sold_by,street_address,city,zip,value,sold_at) VALUES ('" + soldto.to_s + "','" + soldby.to_s.strip + "','" + street_address.to_s + "','" +  city + "','" +  zip + "','" + value.to_s + "','" + sold_at + "')"
			 		
			 		# puts clientP.class
			 		clientP.query("INSERT INTO " + cityP + "(sold_to,sold_by,street_address,city,zip,value,sold_at) VALUES ('" + soldto.to_s + "','" + soldby.to_s.strip + "','" + street_address.to_s + "','" +  city + "','" +  zip + "','" + value.to_s + "','" + sold_at + "')")
			 		

		 		end 

		 		
				# r.xpath('td').each_with_index do |td,j|
				# 	f.puts td.text + "---" + td.text.length.to_s
				# end 
		 	end 
	}
end 

city 		= "Boone"
pageCount 	= 5970 #must be greater than 2

client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :database => "chicagotribune", :password => "")

# client.query("DROP TABLE IF EXISTS `"+ city + "`;")
# client.query("CREATE TABLE " +  city +  " (sold_to TEXT, sold_by TEXT, street_address TEXT, city TEXT, zip TEXT, value TEXT, sold_at TEXT)")

uri 		= URI ("http://chicagotribune.public-record.com/realestate/search/" + city.to_s)
response 	= Net::HTTP.post_form(uri, 'lck' 	 => 'unlocked',
									'lck_2'	 => 'unlocked',
									'sdate'	 => '10/17/2016',
									'edate'	 => '4/17/2017',
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
			puts pageCounter
		end 
		puts "done" 
	end 
end 



