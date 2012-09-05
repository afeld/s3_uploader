require 'rubygems'
require 'bundler'
Bundler.require

require './server'

map '/' do
  run S3UploadApp
end

map '/magickly' do
  run Magickly::App
end
