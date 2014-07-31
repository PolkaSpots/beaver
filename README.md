# Beaver
### Because everyone loves an Eager Beaver ###

Much of this is a shameless copy paste job from gocardless#hutch (https://github.com/gocardless/hutch).

We took much inspiration from Sneakers too (https://github.com/jondot/sneakers). In fact, many thanks to Jondot who encouraged us to create this (well, not quite this).

(Eager) Beaver will ONLY process / consume jobs from a RabbitMQ server. **Do not use this in production yet**, we've just written it and have zero tests while we figure out if it works.

## WHY? What's wrong with Hutch? What's wrong with Sneakers?

Nothing really. But they didn't work for our setup.

We use a multitude of different platforms and therefore publish directly to RabbitMQ with our own methods. We therefore didn't need the produce functions in either Hutch or Sneakers.

Hutch also has (at the current time) no support to send a CA and it was faster for us to create this than patch theirs. Sorry chaps.

Hutch requires access to the RabbitMQ API to clear the bindings out. Whilst this is a lovely idea, we run a heavily locked down cluster on a public IP and didn't want any traffic hitting the API. It was doable but added much work / config changes on our firewalls and chef recipes.

Sneakers is a fabulous repository and we urge you all to try this first. It does however create a connection for each worker which didn't fit with our setup. We didn't have a lot of luck with it in production - we use god as a process monitor which is already famous for memory leaks. We found our servers dying a miserable death after a few hours, even when the connections were reduced to 1.

Finally, we found the Sneakers Rails support lacking and we originally went off to create a sneakers-rails gem. Which we may still do.The principal of Sneaker's consume methods is to consume JSON to be platform independent. We like this a lot, it fits nicely with our multi-language set up.

The only problem is that it doesn't fit when you need access to your Rails models. If you're starting off, try and build your consumers so they accept JSON only and don't really need a db.

So that's that.

Again, Beaver will only consume. It uses the same process method as Hutch.

## Installation

Add this line to your application's Gemfile:

    gem 'beaver', git: "https://github.com/PolkaSpots/beaver"

And then execute:

    $ bundle

Or install it yourself as (not working yet):

    $ gem install beaver

## Usage

TODO: Write usage instructions here. Yeah, this has be to completed.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/beaver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
