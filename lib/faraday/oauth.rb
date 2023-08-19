# frozen_string_literal: true

require_relative "oauth/version"

module Faraday
  module OAuth
    autoload :Middleware, "faraday/oauth/middleware"

    Faraday::Request.register_middleware(oauth: -> { Faraday::OAuth::Middleware })
  end
end
