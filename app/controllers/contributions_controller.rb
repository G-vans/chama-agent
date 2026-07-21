class ContributionsController < ApplicationController
  def create
    @chama = Chama.find(params[:chama_id])
    @member = @chama.members.find(params[:member_id])

    response = DarajaClient.new.stk_push(
      phone_number: @member.phone,
      amount: @chama.contribution_amount,
      account_ref: "member-#{@member.id}",
      description: "Chama contribution"
    )

    if response["CheckoutRequestID"].present?
      Rails.cache.write(
        "daraja:checkout:#{response['CheckoutRequestID']}",
        @member.id,
        expires_in: 30.minutes
      )
    end

    message = "Payment request sent to #{@member.name}"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash", partial: "shared/flash", locals: { notice: message, alert: nil }),
          turbo_stream.replace(
            @member,
            partial: "members/member_row",
            locals: { member: @member, chama: @chama, pending: true }
          )
        ]
      end
      format.html { redirect_to chama_path(@chama), notice: message }
    end
  rescue DarajaClient::AuthenticationError, DarajaClient::StkPushError => error
    Rails.logger.error("M-PESA STK Push failed for member #{@member&.id}: #{error.message}")
    message = "Could not send payment request. Please try again."

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "flash",
          partial: "shared/flash",
          locals: { notice: nil, alert: message }
        ), status: :unprocessable_entity
      end
      format.html { redirect_to chama_path(@chama), alert: message }
    end
  end
end
