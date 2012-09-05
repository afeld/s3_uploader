# S3 Direct Upload

Small example application of direct file uploads to Amazon S3.  Built using Sinatra.  Requires Ruby 1.9.  To run:

1. Create an S3 bucket.
2. Make a copy of `bucket_policy.json.sample` and set your bucket name where you see "`BUCKET_NAME_HERE`".
3. Set environment variables `S3_UPLOADER_S3_BUCKET`, `S3_UPLOADER_S3_ACCESS_KEY` and `S3_UPLOADER_S3_ACCESS_SECRET`.
4. Start the Sinatra app:

    $ bundle install
    $ rackup
    $ open http://localhost:9292
