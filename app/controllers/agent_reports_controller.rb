class AgentReportsController < ApplicationController
  def create
    @chama = Chama.find(params[:chama_id])
    AgentReportService.new(@chama).call

    @latest_report = @chama.agent_reports.order(generated_at: :desc).first
    @report_content = JSON.parse(@latest_report.content)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "agent_report",
          partial: "chamas/agent_report",
          locals: {
            chama: @chama,
            latest_report: @latest_report,
            report_content: @report_content
          }
        )
      }
      format.html { redirect_to chama_path(@chama), notice: "Health report generated." }
    end
  end
end