# frozen_string_literal: true

RSpec.describe Faraday::OAuth::Middleware do
  def auth_header(response)
    response.env.request_headers["Authorization"]
  end

  def auth_values(response)
    auth = auth_header(response)
    return unless auth

    raise "invalid header: #{auth.inspect}" unless auth.sub!("OAuth ", "")

    Hash[*auth.split(/, |=/)]
  end

  let(:client) do
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.get("/") { [200, {}, ""] }
        stub.post("/") { [200, {}, ""] }
      end
      builder.request :oauth, *Array(options)
    end
  end

  def perform(oauth_options = {}, headers = {}, params = {}, method = :get)
    method = :post if params.is_a?(String)

    client.__send__(method, "http://example.com/", params, headers) do |req|
      req.options[:oauth] = oauth_options unless oauth_options.nil?
    end
  end

  context "with empty options" do
    let(:options) { [{}] }

    it "signs request" do
      auth = auth_values(perform)
      expected_keys = %w[ oauth_nonce
                          oauth_signature
                          oauth_signature_method
                          oauth_timestamp
                          oauth_version ]

      expect(auth.keys).to match_array expected_keys
    end
  end

  context "with configured with consumer and token" do
    let(:options) do
      [{ consumer_key: "CKEY",
         consumer_secret: "CSECRET",
         token: "TOKEN",
         token_secret: "TSECRET" }]
    end

    it "adds auth info to the header" do
      auth = auth_values(perform)
      expected_keys = %w[ oauth_consumer_key
                          oauth_nonce
                          oauth_signature
                          oauth_signature_method
                          oauth_timestamp
                          oauth_token
                          oauth_version ]

      expect(auth.keys).to match_array expected_keys
      expect(auth["oauth_version"]).to eq(%("1.0"))
      expect(auth["oauth_signature_method"]).to eq(%("HMAC-SHA1"))
      expect(auth["oauth_consumer_key"]).to eq(%("CKEY"))
      expect(auth["oauth_token"]).to eq(%("TOKEN"))
    end

    it "doesn't override existing header" do
      request = perform({}, "Authorization" => "iz me!")
      expect(auth_header(request)).to eq("iz me!")
    end

    it "can override oauth options per-request" do
      auth = auth_values(perform(consumer_key: "CKEY2"))

      expect(auth["oauth_consumer_key"]).to eq(%("CKEY2"))
      expect(auth["oauth_token"]).to eq(%("TOKEN"))
    end

    it "can turn off oauth signing per-request" do
      expect(auth_header(perform(false))).to be_nil
    end
  end

  context "without configured token" do
    let(:options) { [{ consumer_key: "CKEY", consumer_secret: "CSECRET" }] }

    it "adds auth info to the header" do
      auth = auth_values(perform)
      expect(auth).to include("oauth_consumer_key")
      expect(auth).not_to include("oauth_token")
    end
  end

  context "when handling body parameters" do
    let(:options) do
      [{ consumer_key: "CKEY",
         consumer_secret: "CSECRET",
         nonce: "547fed103e122eecf84c080843eedfe6",
         timestamp: "1286830180" }]
    end

    let(:value) { { "foo" => "bar" } }

    let(:type_json) { { "Content-Type" => "application/json" } }
    let(:type_form) { { "Content-Type" => "application/x-www-form-urlencoded" } }

    extend Forwardable
    def_delegator :"Faraday::Utils", :build_nested_query

    it "does not include the body for JSON" do
      auth_header1 = auth_header(perform({}, type_json, '{"foo":"bar"}'))
      auth_header2 = auth_header(perform({}, type_json, '{"bar":"baz"}'))

      expect(auth_header1).to eq(auth_header2)
    end

    it "includes the body parameters with form Content-Type" do
      auth_header1 = auth_header(perform({}, type_form, { foo: "bar" }))
      auth_header2 = auth_header(perform({}, type_form, { bar: "baz" }))

      expect(auth_header1).not_to eq(auth_header2)
    end

    it "includes the body parameters with an unspecified Content-Type" do
      auth_header1 = auth_header(perform({}, {}, value))
      auth_header2 = auth_header(perform({}, type_form, value))

      expect(auth_header1).to eq(auth_header2)
    end

    it "includes the body parameters for form type with string body" do
      # simulates the behavior of Faraday::MiddleWare::UrlEncoded
      value = { "foo" => %w[bar baz wat] }
      auth_header_hash = auth_header(perform({}, type_form, value, :post))
      auth_header_string = auth_header(perform({}, type_form, build_nested_query(value)))
      expect(auth_header_string).to eq(auth_header_hash)
    end
  end
end
