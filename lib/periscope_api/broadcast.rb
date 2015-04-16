require "pubnub"
class PeriscopeAPI::Broadcast
  attr_reader :attrs

  def initialize(client, attrs)
    @client = client
    @attrs  = attrs
  end

  def share_url
    return nil unless published?

    @share_url ||= begin
      response = @client.post('/api/v2/getBroadcastShareURL', {broadcast_id: broadcast_id})
      response["url"]
    end
  end

  def broadcast_id
    @attrs["broadcast"]["id"]
  end

  def published?
    !!@published
  end

  def publish(status = "", location = {lat: -53.555527, lng: 47.571630})
    return @published if defined?(@published)

    @published = begin
      response = @client.post('/api/v2/publishBroadcast', {
        broadcast_id: broadcast_id,
        friend_chat:  false,
        has_location: true,
        lat:          location[:lat],
        lng:          location[:lng],
        status:       status})

      response["success"]
    end

    start_heartbeat if published?

    @published
  end

  def status
    @client.post('/api/v2/accessChannel', {
      broadcast_id:  broadcast_id,
      entry_ticket:  "",
      from_push:     false,
      uses_sessions: true})
  end

  def start_heartbeat
    return nil unless @published

    pubnub.time(callback: lambda {|msg| puts msg.inspect})
    pubnub.subscribe(
      channel: @attrs["channel"],
      state: { @attrs["channel"] => {
        id: @client.periscope_user_id,
        username: @client.periscope_user_name,
        display_name: @attrs["broadcast"]["user_display_name"],
        pub_nub_profile_image: @attrs["broadcast"]["profile_image_url"],
        participant_index: @attrs["participant_index"]
      }},
      callback: lambda {|msg| channel_msg(msg)})
  end

  def stream_url
    @stream_url ||= begin
      host       = @attrs["host"]
      port       = @attrs["port"]
      name       = @attrs["stream_name"]
      credential = @attrs["credential"]
      app        = @attrs["application"]

      "rtmp://#{host}:#{port}/#{app}?t=#{credential}/#{name}"
    end
  end

private

  def channel_msg(msg)
    puts msg.inspect
  end

  def pubnub
    @pubnub ||= begin
      pn = Pubnub.new(
        subscribe_key: @attrs["subscriber"],
        publish_key:   @attrs["publisher"],
        heartbeat:     10,
        uuid:          "SE:#{@attrs["broadcast"]["user_id"]}",
        error_callback: lambda { |msg|
          $stderr.puts "Error callback says: #{msg.inspect}"
        },
        connect_callback: lambda { |msg|
          $stderr.puts "Connected: #{msg.inspect}"
        },
        logger: nil)

      pn.set_auth_key(@attrs["auth_token"])
      pn
    end
  end
end
