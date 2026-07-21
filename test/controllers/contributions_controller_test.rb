require "test_helper"

class ContributionsControllerTest < ActionDispatch::IntegrationTest
  test "requests an STK push and renders the member as pending" do
    chama = chamas(:one)
    member = members(:one)
    request_arguments = nil
    client = Object.new
    client.define_singleton_method(:stk_push) do |**arguments|
      request_arguments = arguments
      { "ResponseCode" => "0", "CheckoutRequestID" => "checkout-123" }
    end

    original_new = DarajaClient.method(:new)
    DarajaClient.define_singleton_method(:new) { client }

    begin
      post chama_contributions_url(chama),
        params: { member_id: member.id },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    ensure
      DarajaClient.define_singleton_method(:new, original_new)
    end

    assert_response :success
    assert_equal member.phone, request_arguments[:phone_number]
    assert_equal chama.contribution_amount, request_arguments[:amount]
    assert_equal "member-#{member.id}", request_arguments[:account_ref]
    assert_includes response.body, "Payment request sent to #{member.name}"
    assert_includes response.body, "Payment pending"
  end
end
