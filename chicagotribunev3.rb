require 'mysql2'
require 'nokogiri'

client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :database => "chicagotribune", :password => "")

results = client.query("SELECT * FROM ILCounties")

results.each do |row|
	puts row["county"]
end 

county = "test"

client.query("CREATE TABLE "+ county +" (id INT(100), sold_to TEXT, seller TEXT, address TEXT, value DECIMAL(11), sold_at DATE, html TEXT)")

results = client.query("SELECT * FROM pet WHERE id = 1")

results.each do |row|
	temp = row["html"]
	doc = Nokogiri::HTML(temp)

	table = doc.xpath("//table[2]")
	# puts table.children.count
	# puts table

	rows1 = table.xpath("//table[2]/tr")
	puts rows1.count
	rows1.each do |r|
		puts "-------------"
		# puts r
		# puts r.children[2].text.to_s
		r.xpath('td').each_with_index do |td,j|
			puts td.text
		end 
		# puts r.children[3].text.to_s
		# puts r.children[3].innerHtml.to_s
	end 
	
end 

