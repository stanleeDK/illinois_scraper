require 'mysql2'

city = 'cook'
client = Mysql2::Client.new(:host => "db.dev.buildzoom.com", :username => "developer", :database => "tmp", :password => "theknaza!ZoomBuild", :port => "3306")

client.query("CREATE TABLE " +  city +  " (sold_to TEXT, street_address TEXT, city TEXT, zip TEXT, value DECIMAL(10,2), sold_at TEXT)")