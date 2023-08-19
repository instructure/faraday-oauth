# frozen_string_literal: true

require_relative "lib/faraday/oauth/version"

Gem::Specification.new do |spec|
  spec.name = "faraday-oauth"
  spec.version = Faraday::OAuth::VERSION
  spec.authors = ["Cody Cutrer"]
  spec.email = ["cody@instructure.com"]

  spec.summary = "A Faraday middleware that adds an access token to each request."
  spec.description = <<~TEXT
    Uses the simple_oauth library to sign requests according the
    OAuth protocol.
  TEXT
  spec.license = "MIT"

  github_uri = "https://github.com/instructure/#{spec.name}"

  spec.homepage = github_uri

  spec.metadata = {
    "bug_tracker_uri" => "#{github_uri}/issues",
    "changelog_uri" => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
    "documentation_uri" => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => github_uri,
    "wiki_uri" => "#{github_uri}/wiki"
  }

  spec.files = Dir["lib/**/*", "README.md", "LICENSE.md", "CHANGELOG.md"]

  spec.required_ruby_version = ">= 2.7", "< 4"

  spec.add_runtime_dependency "faraday", ">= 1.10", "< 3"
  spec.add_runtime_dependency "simple_oauth", "~> 0.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-inst", "~> 1.0"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
end
