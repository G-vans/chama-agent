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
        handle_failed_request(stk_callback[:CheckoutRequestID])
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
      Rails.cache.delete("daraja:checkout:#{stk_callback[:CheckoutRequestID]}")

      contribution = member.contributions.find_or_create_by!(
        mpesa_receipt: metadata.fetch("MpesaReceiptNumber")
      ) do |record|
        record.amount = metadata.fetch("Amount")
        record.paid_at = Time.zone.strptime(metadata.fetch("TransactionDate").to_s, "%Y%m%d%H%M%S")
        record.status = "completed"
      end

      broadcast_member(member)
      contribution
    end

    def handle_failed_request(checkout_request_id)
      member = member_for_checkout(checkout_request_id)
      return unless member

      if demo_mode?
        member.contributions.create!(
          amount: member.chama.contribution_amount,
          mpesa_receipt: "DEMO-#{checkout_request_id.to_s.last(10)}",
          paid_at: Time.current,
          status: "completed"
        )
        Rails.logger.warn("Daraja demo mode completed the sandbox payment for member #{member.id}")
        broadcast_member(member)
      else
        broadcast_member(member, payment_failed: true)
      end
    end

    def member_for_checkout(checkout_request_id)
      cache_key = "daraja:checkout:#{checkout_request_id}"
      member_id = Rails.cache.read(cache_key)
      Rails.cache.delete(cache_key)
      Member.find_by(id: member_id) if member_id
    end

    def broadcast_member(member, payment_failed: false)
      Turbo::StreamsChannel.broadcast_replace_to(
        "chama_#{member.chama_id}_members",
        target: ActionView::RecordIdentifier.dom_id(member),
        partial: "members/member_row",
        locals: {
          member: member,
          chama: member.chama,
          pending: false,
          payment_failed: payment_failed
        }
      )
    end

    def demo_mode?
      ActiveModel::Type::Boolean.new.cast(ENV.fetch("DARAJA_DEMO_MODE", false))
    end
  end
end
