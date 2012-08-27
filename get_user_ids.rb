require 'twitter'
require File.join(File.expand_path(File.dirname(__FILE__)), ".", "constants.rb") # config info like Twitter username and ID

input_file = ARGV[0]
output_file = ARGV[1]

# test files for testing
# input_file = File.join(File.expand_path(File.dirname(__FILE__)), ".", "input_test.txt")
# output_file = File.join(File.expand_path(File.dirname(__FILE__)), ".", "output_test.csv")

# configure the Twitter client with your info from constants.rb
Twitter.configure do |conf|
   conf.consumer_key = CONSUMER_KEY
   conf.consumer_secret = CONSUMER_SECRET
end

client = Twitter::Client.new(:oauth_access =>
 { 	:key 	=> OAUTH_TOKEN,
	:secret => OAUTH_TOKEN_SECRET
 })

# loop through the screen_names array collecting user_ids
# put those user_ids into output_file

counter = 0
not_found = 0
puts "starting screen name lookup"
begin
  screen_names = IO.readlines(input_file)
  of = File.open(output_file,"w+")
  screen_names.each do |name|
    begin
      counter+=1
      user = client.user(name.chomp) # chomp removes any carriage breaks
      of.puts "\"" + user.screen_name + "\", " + user.id.to_s
    rescue Twitter::Error::NotFound
      not_found+=1
      of.puts "\"" + name.chomp + "\", \"not found\""
    end
  end
rescue => err
  puts "Exception: #{err}"
end
puts "looked up " + counter.to_s + " screen names; " + not_found.to_s + " weren't found."
of.close
