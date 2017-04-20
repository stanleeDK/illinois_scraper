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
		 		
		 		# f.puts r.inner_html
				# <th>Marker</th>
				# <th><a href="http://chicagotribune.public-record.com/realestate/results/1/price:desc" title="Sort by Price">Sort by Price</a></th>
				# <th class="sort_asc"><a href="http://chicagotribune.public-record.com/realestate/results/1/date:asc" title="Sort by Date" class="sort_asc">Sort by Date</a></th>
				# <td align="center" class="alt"><strong>A</strong></td>
				# <td class="alt">$495,000.00<br>
				# <span style="float: right"><a href="javascript:void(0);" onclick="window.open('/realestate/streetview/3972315', '_blank', 'width=600,height=500,scrollbars=yes,status=yes,resizable=yes,screenx=50%,screeny=50%');" title="Street View">Street View</a></span>1446 N BOSWORTH AVE 1N, CHICAGO, 60642-2348<em><br>
				# THERESA E DICKERT sold to MERRICK J DOLL</em>
				# </td>
				# <td align="right" class="alt">03/23/17<br>
				# <div id="3972315-cook"><a href="javascript:%20addToCart('1446+N+BOSWORTH+AVE+1N%2C+CHICAGO%2C+60642%2D2348',3972315,'cook',%20're')">Add to Cart</a></div>
				# </td>

		 		cells = r.xpath('td')
		 		if cells.length > 0 


			 		f.puts "----"
			 		
			 		# f.puts cells[1].inner_html 
			 		value 			= cells[1].inner_html.split("<br>")[0].gsub(/[^\d\.]/, '').to_f
			 		tempAddress 	= cells[1].inner_html.split("</span>")[1].split("<br>")[0].split("<em>")[0].split(",")		
			 		street_address 	= tempAddress[0]
			 		city 			= tempAddress[1].strip
			 		zip 			= tempAddress[2].strip

			 		sold_to 			= cells[1].xpath("em").text.split(" sold to ")[1]
			 		sold_by 			= cells[1].xpath("em").text.split(" sold to ")[0].to_s.strip
			 		sold_at 		= cells[2].text.split("\n")[0].to_s.strip #date 


			 		# soldto = cells[1].xpath("em")
			 		f.puts street_address
			 		f.puts city
			 		f.puts zip
			 		f.puts value
			 		f.puts "sold to: " + sold_to.to_s
			 		f.puts "sold by: " + sold_by.to_s.strip
			 		f.puts sold_at	

			 		# f.puts "INSERT INTO #{cityP} (sold_by, sold_to,street_address,city,zip,value,sold_at) VALUES ('#{sold_by}','#{sold_to}','#{street_address}','#{city}','#{zip}',#{value},'#{sold_at.to_s}')"
			 		clientP.query("INSERT INTO #{cityP} (sold_by, sold_to,street_address,city,zip,value,sold_at) VALUES ('#{sold_by}','#{sold_to}','#{street_address}','#{city}','#{zip}',#{value},'#{sold_at.to_s}')")

		 		end 
		 		
				# r.xpath('td').each_with_index do |td,j|
				# 	f.puts td.text + "---" + td.text.length.to_s
				# end 
		 	end 
	}
end 



# client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :database => "chicagotribune", :password => "")
client = Mysql2::Client.new(:host => "db.dev.buildzoom.com", :username => "developer", :database => "tmp", :password => "theknaza!ZoomBuild", :port => "3306")

client.query("DROP TABLE IF EXISTS `"+ city + "`;")
client.query("CREATE TABLE " +  city +  " (sold_by TEXT, sold_to TEXT, street_address TEXT, city TEXT, zip TEXT, value DECIMAL(10,2), sold_at TEXT)")

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



