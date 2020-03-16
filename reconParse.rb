#!/usr/bin/env ruby
#    A simple script to help extract different types of data from files
#    Author: DJ Nelson

require 'optimist'
require 'nokogiri'
require 'open-uri'
require 'colorize'


# Set up your options parser
opts = Optimist::options do 
  opt :ip, "Extract IP addresses", :type => :string 
  opt :domain, "Extract domain names", :type => :string
  opt :email, "Extract email addresses", :type => :string
  opt :url, "Extract relative URLs", :type => :string
  opt :xml, "Extract URLs from a Burpsuite XML file", :type => :string
end

results = []


def sanitize_non_ascii(string)
  encoding_options = {
    invalid: :replace,
    undef: :replace,
    replace: '_',
  }

  string.encode Encoding.find('ASCII'), encoding_options
end

case
# Scan for valid IP addresses
when opts[:ip]
  data = open(opts[:ip]).read

  results << data.scan(/\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)

  puts results.uniq

# Scan for FQDNs
when opts[:domain]
  data = open(opts[:domain]).read

  results << data.scan(/(?:(https|http)?:\/\/)?(?:www\.)?([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}/ix)

  puts results.uniq

# Scan for email addresses
when opts[:email]
  data = open(opts[:email]).read

  results << data.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
  
  puts results.uniq

# Scan a Burpsuite XML file from URLs
when opts[:xml]
  data = open(opts[:xml]).read

    doc = Nokogiri::XML(File.open(xmlFile, 'r')) do |config|
      config.strict.noblanks
    end
    
    urls = doc.xpath("//url").map do |entry|
      entry.text
    end

    urls.map { |u| u.split("/")[1..-2].join("/").reverse.chop.reverse }.uniq

# Scan a file for relative URL endpoints
when opts[:url]
  data = open(opts[:url]).read
  matched_endpoints = []

  sanitize_non_ascii(data).gsub(/;/, "\n").scan(/(^.*?("|')(\/[\w\d\?\/&=\#\.\!:_-]*?)(\2).*$)/).map do |string|
    next if matched_endpoints.include?(string[2])

    matched_endpoints << string[2]
 
    puts string[2]
  end
else
  puts "You must specify a file to scan!".red
  Optimist::educate
end
