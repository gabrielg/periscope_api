# API documentation

## Overview

Broadly, [Periscope](http://www.periscope.tv/) makes use of four different
services:

### Twitter's xAuth mechanism.

Authentication is provided via Twitter's [xAuth](https://dev.twitter.com/oauth/xauth)
mechanism, using what seems to be largely undocumented (to the public) methods.

### A HTTP API at https://api.periscope.tv.

This is a HTTP API that accepts and returns JSON. Apparently all the cool kids
are eschewing REST these days, because every call uses POST.

### PubNub.

[PubNub](http://pubnub.com) is used for all the pub-sub based parts of the app,
like chat.

### RTMP streaming to Wowza Media Server.

The actual video is streamed to EC2 instances running [Wowza Media Server](http://www.wowza.com)
via [RTMP](http://en.wikipedia.org/wiki/Real_Time_Messaging_Protocol).

### AWS.

Stream thumbnails and replays get uploaded to S3.

## Periscope HTTP API endpoints

### POST https://api.periscope.tv/api/v2/loginTwitter?build=v1.0.2

#### Request Body

```
{
    "bundle_id": "com.bountylabs.periscope",
    "phone_number": "",
    "session_key": "<twitter_user_oauth_key>",
    "session_secret": "<twitter_user_oauth_secret>",
    "user_id": "<twitter_user_id>",
    "user_name": "<twitter_user_name>",
    "vendor_id": "81EA8A9B-2950-40CD-9365-40535404DDE4"
}
```

#### Response Body

```
{
    "cookie": "<a_value_used_for_authenticating_further_requests>",
    "settings": {
        "auto_save_to_camera": false,
        "push_new_follower": false
    },
    "suggested_username": "",
    "user": {
        "class_name": "User",
        "created_at": "2015-04-14T12:35:43.249931849-07:00",
        "description": "",
        "display_name": "Testing",
        "id": "<integer_user_id>",
        "initials": "",
        "is_beta_user": false,
        "is_employee": false,
        "is_twitter_verified": false,
        "n_broadcasts": 0,
        "n_followers": 0,
        "n_following": 1,
        "profile_image_urls": [
            {
                "height": 128,
                "ssl_url": "https://abs.twimg.com/sticky/default_profile_images/default_profile_1_reasonably_small.png",
                "url": "http://abs.twimg.com/sticky/default_profile_images/default_profile_1_reasonably_small.png",
                "width": 128
            },
            {
                "height": 200,
                "ssl_url": "https://abs.twimg.com/sticky/default_profile_images/default_profile_1_200x200.png",
                "url": "http://abs.twimg.com/sticky/default_profile_images/default_profile_1_200x200.png",
                "width": 200
            },
            {
                "height": 400,
                "ssl_url": "https://abs.twimg.com/sticky/default_profile_images/default_profile_1_400x400.png",
                "url": "http://abs.twimg.com/sticky/default_profile_images/default_profile_1_400x400.png",
                "width": 400
            }
        ],
        "twitter_screen_name": "<twitter_screen_name>",
        "updated_at": "2015-04-14T12:35:57.046371902-07:00",
        "username": "<periscope_user_name>"
    }
}
```

### POST https://api.periscope.tv/api/v2/createBroadcast?build=v1.0.2

#### Request Body

```
{
    "cookie": "<cookie_from_loginTwitter_call>",
    "height": 568,  // video height
    "lat": 0.0,     // current location latitude
    "lng": -20.0,   // current location longitude
    "width": 320    // video width
}
```

#### Response Body

```
{
    "application": "liveorigin",
    "auth_token": "<pubnub_auth_token>",
    "broadcast": {
        "Application": "liveorigin",
        "Host": "ec2-52-4-220-111.compute-1.amazonaws.com",
        "OriginId": "i90be606d",
        "Region": "us-east-1",
        "available_for_replay": false,
        "city": "Kings",
        "class_name": "Broadcast",
        "country": "",
        "country_state": "New York",
        "created_at": "2015-04-14T17:24:41.265499812-07:00",
        "featured": false,
        "friend_chat": false,
        "has_location": false,
        "height": 568,
        "hidden": false,
        "id": "<integer_broadcast_id>",
        "image_url": "<s3_url_to_put_thumbnail_to>",
        "image_url_small": "<s3_url_to_put_downsized_thumbnail_to>",,
        "ip_lat": 0.0,    // location latitude
        "ip_lng": -20.0,  // location longitude
        "is_locked": false,
        "iso_code": "",
        "lock": null,
        "profile_image_url": "http://abs.twimg.com/sticky/default_profile_images/default_profile_1_reasonably_small.png",
        "state": "NOT_STARTED",
        "status": "",
        "stream_name": "<string_representing_RTMP_stream_name>",
        "updated_at": "2015-04-14T17:24:41.265499812-07:00",
        "user_display_name": "Testing",
        "user_id": "<periscope_user_id>",
        "width": 320
    },
    "can_share_twitter": true,
    "channel": "<pubnub_channel_name>",
    "credential": "<string_used_as_RTMP_streaming_credential>",
    "host": "ec2-52-4-220-111.compute-1.amazonaws.com", // host to stream RTMP to
    "participant_index": 0,
    "port": 80,
    "private_port": 443,
    "private_protocol": "RTMPS",
    "protocol": "RTMP",
    "publisher": "<pubnub_publisher_key>",
    "read_only": false,
    "signer_token": "<string_including_credential_value>",
    "stream_name": "<same_as_channel_name>",
    "subscriber": "<pubnub_subscriber_key>",
    "thumbnail_upload_url": "<s3_thumbnail_upload_url>",
    "upload_url": "<s3_video_replay_url>"
}
```

### POST https://api.periscope.tv/api/v2/getBroadcastShareURL?build=v1.0.2

#### Request Body

```
{
    "broadcast_id": "<integer_id_returned_from_createBroadcast>",
    "cookie": "<cookie_from_loginTwitter_call>"
}
```

#### Response Body

```
{
    "url": "https://www.periscope.tv/w/<long_string>" // Public video URL that can be visited in a browser
}
```

### POST https://api.periscope.tv/api/v2/publishBroadcast?build=v1.0.2

#### Request Body

```
{
    "broadcast_id": "<integer_id_returned_from_createBroadcast>",
    "cookie": "<cookie_from_loginTwitter_call>",
    "friend_chat": false,
    "has_location": true,
    "lat": 0.0,    // location latitude
    "lng": -20.0,  // location longitude
    "status": ""
}
```

#### Response Body

```
{
    "success": true
}
```

### POST https://api.periscope.tv/api/v2/broadcastMeta?build=v1.0.2

#### Request Body

```
{
    "broadcast_id": "<integer_id_returned_from_createBroadcast>",
    "cookie": "<cookie_from_loginTwitter_call>",
    "stats": {
        "BatteryDrainPerMinute": 0,
        "TransmitOK": true,
        "UploadRate_max": 458,
        "UploadRate_mean": 432,
        "UploadRate_min": 406,
        "UploadRate_stddev": 36.76955262170047,
        "VideoIndexRatio_max": 133.7396760459014,
        "VideoIndexRatio_mean": 104.5064813303835,
        "VideoIndexRatio_min": 86.44113275958026,
        "VideoIndexRatio_stddev": 11.66700863607694,
        "VideoOK": true,
        "VideoOutputRate_max": 534.9587041836056,
        "VideoOutputRate_mean": 418.0259253215341,
        "VideoOutputRate_min": 345.764531038321,
        "VideoOutputRate_stddev": 46.66803454430801,
        "pn_connect_t": 0.2213719,
        "pn_msg_fail": 0,
        "pn_msg_received": 5,
        "pn_msg_sent": 0,
        "pn_prs_received": 1,
        "pn_subscribe_t": 0.839077
    }
}
```

#### Response Body

```
{
    "success": true
}
```

### POST https://api.periscope.tv/api/v2/endBroadcast?build=v1.0.2

#### Request Body

This one is a multipart/form-data request, for some reason. POST it as you would
any regular form submission.

```
broadcast_id:  <integer_id_returned_from_createBroadcast>
cookie:        <cookie_from_loginTwitter_call>
```

### Response Body

```
{
    "broadcast": {
        "AbuseDate": null,
        "AbuseReporter": "",
        "AbuseStatus": "",
        "Application": "liveorigin",
        "Host": "ec2-52-4-220-111.compute-1.amazonaws.com",
        "NAbuseReports": 0,
        "OriginId": "i90be606d",
        "Region": "us-east-1",
        "available_for_replay": false,
        "city": "Kings",
        "class_name": "Broadcast",
        "country": "",
        "country_state": "New York",
        "created_at": "2015-04-14T17:24:41.265499812-07:00",
        "end": "2015-04-14T17:25:01.674845856-07:00",
        "featured": false,
        "friend_chat": false,
        "has_location": true,
        "height": 568,
        "hidden": false,
        "id": "4656494",
        "image_url": "<thumbnail_url>",
        "image_url_small": "<small_thumbnail_url>",
        "ip_lat": 0.0,
        "ip_lng": -20.0,
        "is_locked": false,
        "iso_code": "",
        "join_time_average": 0,
        "join_time_count": 0,
        "lock": null,
        "lost_before_end": 0,
        "n_comments": 0,
        "n_hearts": 0,
        "n_replay_hearts": 0,
        "n_replay_watched": 0,
        "n_watched": 0,
        "n_watching": 0,
        "n_watching_web": 0,
        "n_web_watched": 0,
        "profile_image_url": "http://abs.twimg.com/sticky/default_profile_images/default_profile_1_reasonably_small.png",
        "start": "2015-04-14T17:24:46.518208519-07:00",
        "state": "ENDED",
        "status": "",
        "stream_name": "<stream_name_from_createBroadcast>",
        "updated_at": "2015-04-14T17:25:01.674845856-07:00",
        "user_display_name": "Testing",
        "user_id": "<periscope_user_id>",
        "watched_time": 0,
        "watched_time_calculated": 0,
        "watched_time_implied": 0,
        "width": 320
    }
}
```

### POST https://api.periscope.tv/api/v2/followingBroadcastFeed?build=v1.0.2

*TODO*

### POST https://api.periscope.tv/api/v2/suggestedPeople?build=v1.0.2

*TODO*

### POST https://api.periscope.tv/api/v2/featuredBroadcastFeed?build=v1.0.2

*TODO*

### POST https://api.periscope.tv/api/v2/uploadPadding?build=v1.0.2

*TODO*

### POST https://api.periscope.tv/api/v2/getBroadcastViewers?build=v1.0.2

*TODO*

### POST https://api.periscope.tv/api/v2/replayUploaded?build=v1.0.2

*TODO*

## RTMP Streaming

The `credential` from the `createBroadcast` call should be included in the RTMP
application name. The URL format is then:

```
rtmp://#{host}:#{port}/liveorigin?t=#{credential}/#{stream_name}"
```

FFMPEG (or another other RTMP-capable client) can then be used to stream video.
