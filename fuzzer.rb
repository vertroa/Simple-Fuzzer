#!/usr/bin/env ruby

require 'slop'
require 'cgi'
require 'uri'

opts = Slop.parse do |o|
	o.bool '-g', '--get', 'If you are fuzzing a GET request'
	o.bool '-p', '--post', 'If you are fuzzing a POST request'
	o.string '-u', '--url', 'The URL that you are fuzzing'
	o.string '-c', '--cookie', 'The authenticated cookie if required'
	o.string '-d', '--data', 'Post data if required'
	o.string '-x', '--payloads', 'The text file name containing the fuzzing payloads'
	o.on '-h', '--help', 'display help' do
     puts o
     exit
	end
end

def fuzzer(url, params, file, *cookie)

end

## Intilize variables
uri = ""
request = ""
params = []

## Set request type
if opts[:get] == true
	request = "get" 
	uri = URI(opts[:url])
	params = CGI::parse(uri.query)
elsif opts[:post] == true
	request = "post" 
	params = CGI::parse(opts[:data])
end

params.each do |x, y| 
	puts  "#{x} = #{y}"
end

fuzzer(opts[:url], opts[:file], opts[:cookie])