require "faraday"
require "faraday_middleware"
begin
  require "pry"
rescue LoadError
end

if ENV['DEBUG_HTTP']
  require "httplog"
  HttpLog.options[:log_headers] = true
end

class PeriscopeAPI
  PERISCOPE_UA        = "Periscope/2699 (iPhone; iOS 8.1.2; Scale/2.00)"
  PERISCOPE_BUNDLE_ID = "com.bountylabs.periscope"
  PERISCOPE_VENDOR_ID = "81EA8A9B-2950-40CD-9365-40535404DDE4"
  PERISCOPE_API_URL   = "https://api.periscope.tv"
  BUILD_VERSION       = "v1.0.2"

  def initialize(secret, token, user_id, user_name)
    @secret    = secret
    @token     = token
    @user_id   = user_id
    @user_name = user_name
  end

  def login
    return true if logged_in?

    @login_response = post('/api/v2/loginTwitter', {
      bundle_id:      PERISCOPE_BUNDLE_ID,
      phone_number:   "",
      session_key:    @token,
      session_secret: @secret,
      user_id:        @user_id,
      user_name:      @user_name,
      vendor_id:      PERISCOPE_VENDOR_ID}, false)

    @logged_in = true
  end

  def periscope_user_id
    return nil unless logged_in?

    @login_response["user"]["id"]
  end

  def periscope_user_name
    return nil unless logged_in?
    @login_response["user"]["username"]
  end

  def logged_in?
    !!@logged_in
  end

  def create_broadcast(height = 568, width = 320, location = {lat: -53.555527, lng: 47.571630})
    response = post('/api/v2/createBroadcast', {
      height: height,
      width:  width,
      lat:    location[:lat],
      lng:    location[:lng]})

    Broadcast.new(self, response)
  end

  def post(path, data, merge_cookie = true)
    if merge_cookie && logged_in?
      data = data.merge(cookie: cookie)
    end

    response = connection.post do |request|
      request.url(path)
      request.headers['Content-Type'] = 'application/json'
      request.body = data.to_json
    end

    response.body
  end

private

  def cookie
    return nil unless logged_in?

    @login_response["cookie"]
  end

  def connection
    @connection ||= begin
      conn = Faraday.new(PERISCOPE_API_URL, params: {build: BUILD_VERSION}) do |c|
        c.adapter(Faraday.default_adapter)
        c.use(FaradayMiddleware::ParseJson, content_type: 'application/json')
        c.use(Faraday::Response::RaiseError)
      end

      conn.headers[:user_agent] = PERISCOPE_UA
      conn
    end
  end

  require "periscope_api/broadcast"
end

