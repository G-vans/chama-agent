require "faraday"
require "base64"

class DarajaClient
  class AuthenticationError < StandardError; end
  class StkPushError < StandardError; end

  BASE_URL = "https://sandbox.safaricom.co.ke".freeze

  def initialize
    @consumer_key = ENV.fetch("DARAJA_CONSUMER_KEY")
    @consumer_secret = ENV.fetch("DARAJA_CONSUMER_SECRET")
    @shortcode = ENV.fetch("DARAJA_SHORTCODE")
    @passkey = ENV.fetch("DARAJA_PASSKEY")
    @callback_url = ENV.fetch("DARAJA_CALLBACK_URL")
  end

  # Returns a cached access token, generating a fresh one if expired.
  # Daraja tokens are valid for 3599 seconds (~1 hour).
  def access_token
    Rails.cache.fetch("daraja:access_token", expires_in: 55.minutes) do
      generate_token
    end
  end

  # Triggers an STK Push prompt on the given phone number.
  #
  # phone_number: string in format "2547XXXXXXXX" (no +, no leading 0)
  # amount:       integer (KES)
  # account_ref:  short identifier for the transaction (e.g. member ID)
  # description:  human-readable description shown to the user
  #
  # Returns a Hash with the Daraja response, including CheckoutRequestID
  # which you use to correlate with the callback.
  def stk_push(phone_number:, amount:, account_ref:, description: "Chama contribution")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{@shortcode}#{@passkey}#{timestamp}")

    body = {
      BusinessShortCode: @shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount,
      PartyA: phone_number,
      PartyB: @shortcode,
      PhoneNumber: phone_number,
      CallBackURL: @callback_url,
      AccountReference: account_ref.to_s,
      TransactionDesc: description
    }

    response = connection.post("/mpesa/stkpush/v1/processrequest") do |req|
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Content-Type"] = "application/json"
      req.body = body.to_json
    end

    parsed = JSON.parse(response.body)

    unless response.success? && parsed["ResponseCode"] == "0"
      raise StkPushError, "STK Push failed: #{parsed.inspect}"
    end

    parsed
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |f|
      f.adapter Faraday.default_adapter
    end
  end

  def generate_token
    credentials = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")

    response = connection.get("/oauth/v1/generate") do |req|
      req.params["grant_type"] = "client_credentials"
      req.headers["Authorization"] = "Basic #{credentials}"
    end

    parsed = JSON.parse(response.body)

    unless response.success? && parsed["access_token"]
      raise AuthenticationError, "OAuth failed: #{parsed.inspect}"
    end

    parsed["access_token"]
  end
end