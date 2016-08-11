#! /usr/bin/env ruby

require 'aes'
require 'colorize'

def generate_secret
  AES.key
end

def output_secret 
    puts "","Your unique secret is:",""
    puts generate_secret.light_green 
    puts "","Copy this secret, then set the config var for your Heroku app by running:",""
    puts "heroku config:set SECRET=".blue + "<your_key_here>".light_green
end

output_secret