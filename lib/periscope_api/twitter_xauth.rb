require "oauth"

# The OAuth gem modifies the headers to add the gem version and this can't be
# disabled, so here's a nugget of grossness.
OAuth::Client::Helper.class_eval do
  def amend_user_agent_header(headers)
    return headers
  end
end

class PeriscopeAPI::TwitterXAuth
  PERISCOPE_TWITTER_UA    = "Periscope/2699 CFNetwork/711.1.16 Darwin/14.0.0"
  DEFAULT_TWITTER_HEADERS = {"User-Agent" => PERISCOPE_TWITTER_UA}
  TWITTER_API_URL         = "https://api.twitter.com"

  def initialize(options = {})
    @twitter_consumer_key      = options[:twitter_consumer_key]
    @twitter_consumer_secret   = options[:twitter_consumer_secret]
    @periscope_consumer_key    = options[:periscope_consumer_key]
    @periscope_consumer_secret = options[:periscope_consumer_secret]
  end

  def authenticate(username, password)
    user_secret, user_token = get_twitter_oauth(username, password)
    auth_header = get_reverse_auth_header

    xauth_access_token = get_xauth_access_token(
      auth_header,
      @periscope_consumer_key,
      user_secret,
      user_token)

    return {
      secret:      xauth_access_token.secret,
      token:       xauth_access_token.token,
      user_id:     xauth_access_token.params[:user_id],
      screen_name: xauth_access_token.params[:screen_name]}
  end

private

  def get_twitter_oauth(username, password)
    consumer = OAuth::Consumer.new(
      @twitter_consumer_key,
      @twitter_consumer_secret,
      site: TWITTER_API_URL)

    token = consumer.get_access_token(
      nil,
      {},
      { x_auth_username: username,
        x_auth_password: password,
        x_auth_mode: "client_auth" },
      DEFAULT_TWITTER_HEADERS)

    return token.secret, token.token
  end

  def get_reverse_auth_header
    consumer = OAuth::Consumer.new(
      @periscope_consumer_key,
      @periscope_consumer_secret,
      site: TWITTER_API_URL)

    reverse_auth_response = nil

    consumer.get_request_token({}, {x_auth_mode: "reverse_auth"}, DEFAULT_TWITTER_HEADERS) do |response_body|
      reverse_auth_response = response_body.dup
    end
  rescue TypeError => e
    # oauth-ruby doesn't properly handle the xAuth response.
    $stderr.puts("Expected error handling xAuth reverse_auth response: #{e.inspect}")
    return reverse_auth_response
  end

  def get_xauth_access_token(reverse_auth_parameters, reverse_auth_target, user_secret, user_token)
    consumer = OAuth::Consumer.new(
      @twitter_consumer_key,
      @twitter_consumer_secret,
      site: TWITTER_API_URL)

    request_token = OAuth::RequestToken.new(consumer, user_token, user_secret)

    consumer.get_access_token(
      request_token,
      {},
      { adc: "phone",
        x_reverse_auth_parameters: reverse_auth_parameters,
        x_reverse_auth_target: reverse_auth_target },
      DEFAULT_TWITTER_HEADERS)
  end
end
