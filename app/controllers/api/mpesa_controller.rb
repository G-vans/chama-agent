module Api
  class MpesaController < ApplicationController
    skip_forgery_protection only: :callback

    def callback
      stk_callback = params.dig(:Body, :stkCallback) || {}

      if stk_callback[:ResultCode].to_i.zero?
        record_contribution(stk_callback)
      else
        Rails.logger.warn(
          "M-PESA callback failed: #{stk_callback[:ResultDesc]} " \
          "(CheckoutRequestID: #{stk_callback[:CheckoutRequestID]})"
        )
        broadcast_failed_request(stk_callback[:CheckoutRequestID])
      end
    rescue StandardError => error
      # Acknowledge callbacks even when a malformed payload cannot be processed,
      # otherwise Daraja will repeatedly retry the same webhook.
      Rails.logger.error("Could not process M-PESA callback: #{error.class}: #{error.message}")
    ensure
      render json: { ResultCode: 0, ResultDesc: "Accepted" }
    end

    private

    def record_contribution(stk_callback)
      metadata = Array(stk_callback.dig(:CallbackMetadata, :Item)).to_h do |item|
        [item[:Name], item[:Value]]
      end

      member = Member.find_by!(phone: metadata.fetch("PhoneNumber").to_s)
      contribution = member.contributions.create!(
        amount: metadata.fetch("Amount"),
        mpesa_receipt: metadata.fetch("MpesaReceiptNumber"),
        paid_at: Time.zone.strptime(metadata.fetch("TransactionDate").to_s, "%Y%m%d%H%M%S"),
        status: "completed"
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        "chama_#{member.chama_id}_members",
        target: ActionView::RecordIdentifier.dom_id(member),
        partial: "members/member_row",
        locals: { member: member, chama: member.chama, pending: false }
      )

      contribution
    end

    def broadcast_failed_request(checkout_request_id)
      cache_key = "daraja:checkout:#{checkout_request_id}"
      member_id = Rails.cache.read(cache_key)
      Rails.cache.delete(cache_key)
      return unless member_id

      member = Member.find_by(id: member_id)
      return unless member

      Turbo::StreamsChannel.broadcast_replace_to(
        "chama_#{member.chama_id}_members",
        target: ActionView::RecordIdentifier.dom_id(member),
        partial: "members/member_row",
        locals: { member: member, chama: member.chama, pending: false, payment_failed: true }
      )
    end
  end
end
