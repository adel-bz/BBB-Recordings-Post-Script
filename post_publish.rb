#!/usr/bin/ruby
# encoding: UTF-8

# Require necessary gems
require "optimist"
require 'net/http'
require 'uri'
require 'json'
require "zip"
require File.expand_path('../../../lib/recordandplayback', __FILE__)

# Parse command line options
opts = Optimist::options do
  opt :meeting_id, "Meeting id to archive", :type => String
  opt :format, "Playback format name", :type => String
end

# Assign meeting_id from command line options
meeting_id = opts[:meeting_id]

# Define the path to the published files
published_files = "/var/bigbluebutton/published/video/#{meeting_id}"

# Get the meeting metadata
meeting_metadata = BigBlueButton::Events.get_meeting_metadata("/var/bigbluebutton/recording/raw/#{meeting_id}/events.xml")


# Create a logger
logger = Logger.new("/var/log/bigbluebutton/post_publish.log", 'weekly' )
logger.level = Logger::INFO
BigBlueButton.logger = logger


# Define the path to the zip file
zip_file_path = "/var/bigbluebutton/published/video/#{meeting_id}.zip"

# Create a zip file and add all files in the published_files directory to it
Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
  Dir[File.join(published_files, '**', '**')].each do |file|
    zipfile.add(file.sub(published_files + '/', ''), file)
  end
end


# Set AWS environment variables and other
ENV['AWS_ACCESS_KEY_ID'] = '$AWS_ACCESS_KEY_I'
ENV['AWS_SECRET_ACCESS_KEY'] = '$AWS_SECRET_ACCESS_KEY'
ENV['AWS_REGION'] = '$AWS_REGION'
bucket_name = '$bucket_name'
discord_webhook_url = '$discord_webhook_url'
bbb_domain = '$bbb_domain'


# Upload files to S3
BigBlueButton.logger.info("S3 Uploader Running.")
meeting_id = "#{meeting_id}"
aws_s3_cmd = "aws s3 cp " + zip_file_path + " s3://#{bucket_name}/"
output = `#{aws_s3_cmd}`
status = $?.success?


# Log the command, output, and status
BigBlueButton.logger.info("Command: #{aws_s3_cmd}")
BigBlueButton.logger.info("Output: #{output}")
BigBlueButton.logger.info("Status: #{status}")


# Remove the zip file after uploading
File.delete(zip_file_path)


# Define the webhook URL
webhook_url = "#{discord_webhook_url}"

# Get the current time
current_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

# Define the message content
message_content = "```Meeting ID: #{meeting_id}```"
message_content += "```Downloading URL:\nhttps://s3.amazo[naws.com/#{bucket_name}/#{meeting_id}.zip```"
message_content += "```Streaming Recording URL: https://#{bbb_domain}/playback/video/#{meeting_id}\n\n//Note: The streaming link will be expired after 14 days.```"
message_content += "```Current Time: #{current_time}\nStatus: #{status}```\n"
message_content += "---------------------------------------------------------------------------------------------------------------\n"
message_content += "---------------------------------------------------------------------------------------------------------------\n"

# Create a hash representing the message payload
payload = {
  content: message_content
}

# Convert the payload to JSON
json_payload = payload.to_json

# Parse the webhook URL
uri = URI.parse(webhook_url)

# Create an HTTP POST request with the JSON payload
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request.body = json_payload

# Send the HTTP request
response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

# Log that the script has ended
BigBlueButton.logger.info("End Script")

exit 0
