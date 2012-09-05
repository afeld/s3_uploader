require 'base64'
require 'openssl'
require 'digest/sha1'
require 'securerandom'

class S3UploadApp < Sinatra::Base
  enable :sessions

  configure :development do
    set upload_callback_url: 'http://localhost:9292/uploaded'
  end

  configure :production do
    host = ENV['HOST'] || raise("HOST must be set")
    set upload_callback_url: "http://#{host}/uploaded"
  end

  configure do
    set :s3_bucket, (ENV['S3_UPLOADER_S3_BUCKET'] || raise("please set S3_UPLOADER_S3_BUCKET"))
    s3_key = ENV['S3_UPLOADER_S3_ACCESS_KEY'] || raise("please set S3_UPLOADER_S3_ACCESS_KEY")
    s3_secret = ENV['S3_UPLOADER_S3_ACCESS_SECRET'] || raise("please set S3_UPLOADER_S3_ACCESS_SECRET")

    # policy setup from http://aws.amazon.com/articles/1434?_encoding=UTF8&jiveRedirect=1
    policy_document = ERB.new(File.read("#{settings.root}/views/policy_doc.erb")).result(binding)
    policy = Base64.encode64(policy_document).gsub("\n", '')

    signature = Base64.encode64(
      OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), s3_secret, policy)
    ).gsub("\n", '')

    set(
      s3_key: s3_key,
      s3_secret: s3_secret,
      s3_policy: policy,
      s3_signature: signature,
      # set the secret so session will be persisted across app restarts
      session_secret: s3_secret
    )
  end


  helpers do
    def upload_key
      "uploads/#{SecureRandom.uuid}/${filename}"
    end

    def masked_url orig_url, mask_num
      uri = Addressable::URI.parse('/magickly')
      uri.query_values = { mustachify: mask_num, src: orig_url }
      uri.to_s
    end
  end


  get '/' do
    # check if they've already uploaded something
    if session[:upload_url]
      mask_num = session[:last_mask_num]
      if mask_num
        redirect "/share/#{mask_num}"
      else
        redirect "/pick_mask"
      end
    else
      redirect '/upload'
    end
  end

  get '/upload' do
    haml :upload
  end

  get '/uploaded' do
    session[:upload_url] = "http://s3.amazonaws.com/#{params[:bucket]}/#{params[:key]}"
    redirect '/pick_mask'
  end

  get '/pick_mask' do
    haml :pick_mask
  end

  get '/share/:mask_num' do
    redirect '/upload' unless session[:upload_url]
    session[:last_mask_num] = params[:mask_num]
    haml :share
  end
end
