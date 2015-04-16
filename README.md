# Periscope API

```
              _-.
             ( (o)
  "     _    |_|"
     -       | |                  _                                  _
  " -   -" -.| |    _ __  ___ _ _(_)___ __ ___ _ __  ___   __ _ _ __(_)
      -   " -| |   | '_ \/ -_) '_| (_-</ _/ _ \ '_ \/ -_) / _` | '_ \ |
    "   _" -.|,!)  | .__/\___|_| |_/__/\__\___/ .__/\___|_\__,_| .__/_|
   "-     `" -='   |_|                        |_|      |___|   |_|
```

## Overview

This is a proof-of-concept Ruby client against the [Periscope](http://www.periscope.tv/)
API. Use at your own risk.

## How?

The knowledge just came to me in a dream, and/or I reverse-engineered it by
tinkering with the running iOS app and sniffing network traffic.

## Can I throw big old-timey canvas sacks of cash at you to do this for a living?

[Yes, I just moved to New York and I am now available to help you make your computers compute](http://www.gironda.org/cv/).

## How long did this take you?

Probably less time than you'd think.

## What about the Periscope OAuth keys?

This gem comes without batteries included, my friend. You can read a little
about [iOS reverse engineering on my site](http://www.gironda.org), and then
forge your own path into the land of secret-pilfering.

## Okay, I have the keys, I just want to stream a video.

I haven't tested this without signing up for Periscope in the iOS client first.
YMMV.

```
$ export TWITTER_USERNAME=<your_twitter_username>
$ export TWITTER_PASSWORD=<your_twitter_password>
$ export IOS_CONSUMER_KEY=<twitter_consumer_key>
$ export IOS_CONSUMER_SECRET=<twitter_consumer_secret>
$ export PERISCOPE_CONSUMER_KEY=<periscope_consumer_key>
$ export PERISCOPE_CONSUMER_SECRET=<periscope_consumer_secret>
$ periscope-api-stream your-video.mp4
```

## Can I just like, pay you for the keys so I can ruin Periscope with spam?

No.

## What works in this gem?

Logging in and rudimentary stream publishing. [ffmpeg](https://www.ffmpeg.org) is
required for streaming.

## What needs fixing?

Everything else. This code is terrible and was never intended for production
use, so it's missing tests, and the heartbeat mechanism is kinda broken, so your
stream is prone to just ending at some point. The full API isn't really
implemented.

## Do you have documentation for just the HTTP API itself?

Kinda. See [API.md](API.md).

## Will you accept pull requests to make this into a real usable gem?

Yes, with two caveats:

1. I will not just give you the required OAuth credentials to work on this.
2. I will _definitely_ not just give you the required OAuth credentials to work on this.

## Contributing

1. Fork it ( https://github.com/gabrielg/periscope_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
