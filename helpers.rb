helpers do
  # compose a link tag
  def link_tag(args={})
    "<a href=\"#{args[:to]}\"" + " class=\"#{args[:class]}\" " + ">#{args[:name]}</a>"
  end
  
  # pretty time format
  def pretty_time(t)
    t.strftime("%m/%d/%y")
  end
  
  # returns url for gravatar
  def gravatar(args={})
    email = args[:email]
    size = args[:size] || 100
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}&d=monsterid"
  end

  def authenticate!
    if !@user 
     redirect '/'
    end
  end
  
  def s3_connect
    AWS::S3::Base.establish_connection!(
      :access_key_id     => AWS_ACCESS_KEY,
      :secret_access_key => AWS_SECRET
    )
  end
end