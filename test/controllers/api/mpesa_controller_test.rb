require "test_helper"

class Api::MpesaControllerTest < ActionDispatch::IntegrationTest
  test "records a successful callback and acknowledges Daraja" do
    member = members(:one)
    member.update!(phone: "254708374149")

    assert_difference("Contribution.count", 1) do
      post api_mpesa_callback_url, params: successful_payload, as: :json
    end

    assert_response :success
    assert_equal({ "ResultCode" => 0, "ResultDesc" => "Accepted" }, response.parsed_body)

    contribution = Contribution.order(:created_at).last
    assert_equal member, contribution.member
    assert_equal 5_000, contribution.amount
    assert_equal "QAB1234ABC", contribution.mpesa_receipt
    assert_equal "completed", contribution.status
    assert_equal [0, 0, 14, 21, 7, 2026], contribution.paid_at.in_time_zone.to_a.first(6)
  end

  test "acknowledges a failed callback without recording a contribution" do
    Rails.cache.write("daraja:checkout:checkout-id", members(:one).id)

    assert_no_difference("Contribution.count") do
      post api_mpesa_callback_url,
        params: {
          Body: {
            stkCallback: {
              MerchantRequestID: "merchant-id",
              CheckoutRequestID: "checkout-id",
              ResultCode: 1032,
              ResultDesc: "Request cancelled by user"
            }
          }
        },
        as: :json
    end

    assert_response :success
    assert_equal({ "ResultCode" => 0, "ResultDesc" => "Accepted" }, response.parsed_body)
  end

  test "demo mode completes a failed sandbox callback for its correlated member" do
    original_cache = Rails.cache
    original_demo_mode = ENV["DARAJA_DEMO_MODE"]
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ENV["DARAJA_DEMO_MODE"] = "true"
    member = members(:one)
    Rails.cache.write("daraja:checkout:checkout-id", member.id)

    assert_difference("Contribution.count", 1) do
      post api_mpesa_callback_url, params: failed_payload, as: :json
    end

    contribution = Contribution.order(:created_at).last
    assert_equal member, contribution.member
    assert_equal member.chama.contribution_amount, contribution.amount
    assert_equal "DEMO-heckout-id", contribution.mpesa_receipt
    assert_equal "completed", contribution.status
  ensure
    Rails.cache = original_cache
    ENV["DARAJA_DEMO_MODE"] = original_demo_mode
  end

  private

  def successful_payload
    {
      Body: {
        stkCallback: {
          MerchantRequestID: "merchant-id",
          CheckoutRequestID: "checkout-id",
          ResultCode: 0,
          ResultDesc: "The service request is processed successfully.",
          CallbackMetadata: {
            Item: [
              { Name: "Amount", Value: 5_000 },
              { Name: "MpesaReceiptNumber", Value: "QAB1234ABC" },
              { Name: "TransactionDate", Value: 20_260_721_140_000 },
              { Name: "PhoneNumber", Value: 254_708_374_149 }
            ]
          }
        }
      }
    }
  end

  def failed_payload
    {
      Body: {
        stkCallback: {
          MerchantRequestID: "merchant-id",
          CheckoutRequestID: "checkout-id",
          ResultCode: 1037,
          ResultDesc: "DS timeout user cannot be reached."
        }
      }
    }
  end
end
