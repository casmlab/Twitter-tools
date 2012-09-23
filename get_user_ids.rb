require 'twitter'
require File.join(File.expand_path(File.dirname(__FILE__)), ".", "constants.rb") # config info like Twitter username and ID

#for our command line options
options = {}
options[:batch] = 100

optparse = OptionParser.new do |opts|

  opts.on('-b', '--batch SIZE', 'Batch size to use in request.') do |size|
    options[:batch] = size.to_i
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end

end

optparse.parse!

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
found = 0
puts "starting screen name lookup"
begin
  screen_names = IO.readlines(input_file)
  of = File.open(output_file,"w+")
  screen_names.each_slice(options[:batch]) do |names|
    begin
      counter+=names.count
      name_list = names.map { |name| name.chomp }
      users = client.users(name_list) # chomp removes any carriage breaks
      users.each do |user|
        of.puts "\"" + user.screen_name + "\", " + user.id.to_s
        found += 1 if user != nil
      end
    rescue Twitter::Error::NotFound => e
      not_found += 1
      # note: it looks like this would only occur
      # if we were looking up on screen name and it
      # fails. if we are looking up a list, it will
      # just fail silently on those that don't exist.
      of.puts "\"" + name.chomp + "\", \"not found\""
    end
  end

  if counter > 0 and counter != found then
    not_found = counter - found
  end

rescue => err
  puts "Exception: #{err}"
end
puts "looked up " + counter.to_s + " screen names; " + not_found.to_s + " weren't found."
of.close
