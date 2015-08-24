#!/usr/bin/env ruby

require 'slop'
require 'cgi'
require 'uri'
require 'faraday'

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

## Method that places the fuzzing requests 
def fuzzer(url, payloads, params, request, uri, *cookie) 
	## Configures the connection settings
	conn_options = Hash.new
		conn_options[:proxy] = 'http://127.0.0.1:8080'

	## Creates a new HTTP connection
	conn = Faraday.new(uri, conn_options)

	if request == "GET"
		fuzzer_get(conn, payloads, params, uri, *cookie)
	elsif request == "POST"
		fuzzer_post(conn, payloads, params, uri, *cookie)
	end

end

def fuzzer_get(conn, payloads, params, uri, *cookie)
	get_params = ""

	conn.get do |req|
		params.each do |param, value|
			get_params.concat("?#{param}=TEST&")
		end

		payloads.each do |payload|
			payload.strip!
			get = get_params 
			get = get.gsub "TEST", "#{payload}"
			get = get[0...-1]

			req.url uri.path + get
			req.headers['Cookie'] = cookie
		end
	end
end

def fuzzer_post(conn, payloads, params, uri, *cookie)
	post_data = ""

	## Generates the post data
	params.each do |param, value|
		post_data.concat("#{param}=TEST&")
	end

	payloads.each do |payload|

		# Inserts payload into the parameters
		payload.strip!
		post = post_data
		post = post.gsub "TEST", "#{payload}"
		post = post[0...-1]

		## Places the post request
		conn.post do |req|
			req.url uri.path 
			req.headers['Cookie'] = cookie 
			req.body = post 
			#req.body = 'employee_id=101&password=test&action=Login'
		end		
	end
end

## Initialize variables
uri = ""
request = ""
params = []
payloads = []

begin
    payloads_file = File.open(opts[:payloads],"r")
rescue
    p "No file found matching #{opts[:payloads]}"
    exit
end

## Set request type & parse params
if opts[:get] == true
	request = "GET" 
	uri = URI(opts[:url])
	params = CGI::parse(uri.query)
elsif opts[:post] == true
	request = "POST" 
	uri = URI(opts[:url])
	params = CGI::parse(opts[:data])
end

## Import payloads from file
payloads_file.each do |payload|
	payloads.push(payload)
end 

fuzzer(opts[:url], payloads, params, request, uri, opts[:cookie])