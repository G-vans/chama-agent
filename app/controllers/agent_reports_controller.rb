class AgentReportsController < ApplicationController
  def create
    chama = Chama.find(params[:chama_id])
    AgentReportService.new(chama).call
    redirect_to chama_path(chama), notice: "Health report generated."
  end
end