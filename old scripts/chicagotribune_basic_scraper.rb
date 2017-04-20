require 'open-uri'
require 'nokogiri'
# require 'mechanize'
require 'net/http'


 uri = URI ("http://chicagotribune.public-record.com/realestate/search/boone")
 response = Net::HTTP.post_form(uri,'lck' 	=> 'unlocked',
 									'lck_2'		=> 'unlocked',
 									'sdate'	=> '7/25/2016',
 									'edate'	=> '1/25/2017',
 									'radio1'	=> 'city',
 									'radio2'	=> 'range',
 									'submit' => 'Start Searching Now'
 	)

  # response.inspect;
  # puts response.body
  # puts response.code
	# location = response['location']
	# res2 = Net::HTTP.get_response(URI(location))
	# puts res2.body


case response 
when Net::HTTPRedirection then 
	# puts "hello"
	location = response['location']
	location = URI.parse("http://chicagotribune.public-record.com" + location.to_s)
	puts location 
	puts response.to_hash.inspect
	puts "---"
	puts response['set-cookie'].to_s

	http = Net::HTTP.new(location.host,location.port)
	req = Net::HTTP::Get.new(location.request_uri)
	req['Cookie'] = response['set-cookie'].to_s
	# res2 = Net::HTTP.get_response(URI(location))
	puts "----"
	puts req.to_hash.inspect
	res = http.request(req)
	
	puts res.code
	 puts res.body
	 puts "hello"

	case res 
	when Net::HTTPRedirection then 
		location2 = res['location']	
		location2 = URI.parse("http://chicagotribune.public-record.com" + location2.to_s)
		puts location2


		http2 = Net::HTTP.new(location2.host,location2.port)
		req2 = Net::HTTP::Get.new(location2.request_uri)
		req2['Cookie'] = response['set-cookie'].to_s
		# res2 = Net::HTTP.get_response(URI(location))
		res3 = http.request(req2)

		puts res3.code
		# puts res3.body
		puts "test"

		open('chicagotribune output.html', 'w') { |f|
 			 f.puts res3.body
		}

		nextloc = URI.parse("http://chicagotribune.public-record.com/realestate/results/2/date:desc")
		http3 = Net::HTTP.new(nextloc.host,nextloc.port)
		req3 = Net::HTTP::Get.new(nextloc.request_uri)
		req3['Cookie'] = response['set-cookie'].to_s
		res9 = http3.request(req3)
		
		open('chicagotribune output2.html', 'w') { |f|
 			 f.puts res9.body
		}



	end 
	# case res3
	# when Net::HTTPRedirection then 
	# 	location3 = res3['location']	
	# 	puts location3
	# 	location3 = URI.parse("http://chicagotribune.public-record.com" + location3.to_s)

	# 	http3 = Net::HTTP.new(location3.host,location3.port)
	# 	req3 = Net::HTTP::Get.new(location3.request_uri)
	# 	req3['Cookie'] = "ctRE=session%5Fid=ctre%2D2017126%2Dcaufa%2D19507%2Dvchzy; expires=Fri, 27-Jan-2017 09:51:08 GMT; domain=public-record.com; path=/"
	# 	# res2 = Net::HTTP.get_response(URI(location))
	# 	res4 = http.request(req3)

	# 	# puts res4.code
	# 	# puts res4.body
	# 	puts "test"
	# end 
	
end 
