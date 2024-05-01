# BigBlueButton S3 Uploader and Discord Notifier
This script automates the process of uploading recorded video files from a BigBlueButton server to an AWS S3 bucket and then notifying a Discord channel about the upload.

# Prerequisites
Before using this script, make sure you have the following:

- Ruby installed on your system
- Required Ruby gems installed (optimist, zip, net-http, json)
- An AWS Account and configured with appropriate permissions
- Access to a Discord webhook URL for sending notifications
- Access to the BigBlueButton server with the recordings you want to upload

# Usage

1. Clone this repository to your local machine:

```
git clone https://github.com/adel-bz/BBB-Recordings-Post-Script.git
```

2. Move `post_publish.rb` to `/usr/local/bigbluebutton/core/scripts/post_publish`

```
cd BBB-Recordings-Post-Script
mv post_publish.rb /usr/local/bigbluebutton/core/scripts/post_publish
```

3. Install required gems:

```
gem intall zip 
```

# Configuration
1. Before running the script, make sure to configure the following environment variables:

- `AWS_ACCESS_KEY_ID:` Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY:` Your AWS secret access key
- `AWS_REGION:` The AWS region where your S3 bucket is located
- `bucket_name:` The name of your S3 bucket
- `discord_webhook_url:` The URL of your Discord webhook
- `bbb_domain:` The domain of your BigBlueButton server

To change Environments edit post_publish.rb
```
nano post_publish.rb
```

2. choosing recording format as you need:
> **Note:**
> If your using video format for recording, skip this session.

If you are using presentation format for recordings, you have to change ` published_files = "/var/bigbluebutton/published/video/#{meeting_id}"` to `published_files = "/var/bigbluebutton/published/presentation/#{meeting_id}"`

to install additional recording processing formats see here:
https://docs.bigbluebutton.org/administration/customize/#install-additional-recording-processing-formats

3. Write bucket policy to access AWS S3 with spesfict IPs to download recording files:
```
# If you want to access to s3 bucket with all ips, you can delete condition section: "Not Recommended"
{
    "Version": "2012-10-17",
    "Id": "S3PolicyId1",
    "Statement": [
        {
            "Sid": "IPAllow",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::bbb-records/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "ip1/32",
                        "ip2/32",
                        "ip3/32" 
                    ]
```


If everything is right after each publish recording, recording files are sent to S3, Also some information such as `meeting_id` and `download link` are sent to your Discord channel automatically.


# References

https://docs.bigbluebutton.org/development/recording/#writing-post-scripts


# Contributing

Contributions are welcome! If you find any bugs or have suggestions for improvement, please open an issue or submit a pull request.