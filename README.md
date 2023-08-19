# Faraday OAuth

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/instructure/faraday-oauth/ci)](https://github.com/instructure/faraday-oauth/actions?query=branch%3Amain)
[![Gem](https://img.shields.io/gem/v/faraday-oauth.svg?style=flat-square)](https://rubygems.org/gems/faraday-oauth)
[![License](https://img.shields.io/github/license/instructure/faraday-oauth.svg?style=flat-square)](LICENSE.md)

A Faraday middleware that adds an access token to each request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday-oauth'
```

## Usage and configuration

You have to use the middleware in the Faraday instance that you want to.

```ruby

client = Faraday.new do |builder|
  builder.use :oauth, {:consumer_key => consumer_key, :consumer_secret => consumer_secret, :body_hash => body_hash}

  builder.adapter Faraday.default_adapter
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
