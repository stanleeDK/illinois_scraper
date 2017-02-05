require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'mysql2'



city = "cook"

client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :database => "chicagotribune", :password => "")
client.query("DROP TABLE IF EXISTS `"+ city + "`;")

client.query("CREATE TABLE " +  city +  " (id INT(100), sold_to TEXT, seller TEXT, address TEXT, value DECIMAL(11), sold_at DATE, html TEXT)")

uri = URI ("http://chicagotribune.public-record.com/realestate/search/" + city.to_s)

response = Net::HTTP.post_form(uri, 'lck' 	 => 'unlocked',
									'lck_2'	 => 'unlocked',
									'sdate'	 => '7/25/2016',
									'edate'	 => '1/25/2017',
									'radio1' => 'city',
									'radio2' => 'range',
									'submit' => 'Start Searching Now'
								)

case response 
when Net::HTTPRedirection then 
	
	location 		= response['location']
	location 		= URI.parse("http://chicagotribune.public-record.com" + location.to_s)
	
	http 			= Net::HTTP.new(location.host,location.port)
	req 			= Net::HTTP::Get.new(location.request_uri)
	req['Cookie'] 	= response['set-cookie'].to_s
	
	res 			= http.request(req)

	puts res.code;
	
	case res 
	when Net::HTTPRedirection then 

		location2 		= res['location']	
		location2 		= URI.parse("http://chicagotribune.public-record.com" + location2.to_s)
		http2 			= Net::HTTP.new(location2.host,location2.port)
		req2 			= Net::HTTP::Get.new(location2.request_uri)
		req2['Cookie'] 	= response['set-cookie'].to_s
		
		res3 			= http.request(req2)

		puts res3.code 

	
		fileName = "chicagotribune output" + city + "1.html"
		open(fileName, 'w') { |f|
 			 f.puts res3.body
		}

		pageCounter 	= "2"

		for i in 2..3 #2847

			nextloc 		= URI.parse("http://chicagotribune.public-record.com/realestate/results/" + pageCounter.to_s + "/date:desc")
			http3 			= Net::HTTP.new(nextloc.host,nextloc.port)
			req3 			= Net::HTTP::Get.new(nextloc.request_uri)
			req3['Cookie'] 	= response['set-cookie'].to_s

			res9 			= http3.request(req3)

			puts res9.code
			
			fileName2 = "chicagotribune output"+ city + pageCounter.to_s + ".html"

			client.query("INSERT INTO " + city + "(id,html) VALUES (" + i.to_s + ",'" + res9.body + "')")
			# puts "INSERT INTO " + city + "(id,sold_to,seller,address,value,sold_at,html) VALUES (" + i.to_s + ",,,,,,'" + city + "')"
			

			open(fileName2, 'w') { |f|
	 			 f.puts res9.body
			}
			pageCounter = pageCounter.succ 
			puts pageCounter
		end 
		puts "done" 
	end 
end 