class MembersController < ApplicationController
  def statement
    @member = Member.find(params[:id])

    pdf = MemberStatementPdf.new(@member).render

    send_data pdf,
              filename: "#{@member.name.parameterize}-statement-#{Date.today}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end