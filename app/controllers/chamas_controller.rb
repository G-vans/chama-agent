class ChamasController < ApplicationController
  def index
    @chamas = Chama.all
    # Auto-redirect if only one chama (nice for demo)
    redirect_to chama_path(@chamas.first) if @chamas.count == 1
  end

  def show
    @chama = Chama.find(params[:id])
    @members = @chama.members.includes(:contributions).order(:name)
    @latest_report = @chama.agent_reports.order(generated_at: :desc).first
    @report_content = @latest_report ? JSON.parse(@latest_report.content) : nil
    @latest_chat_analysis = @chama.chat_analyses.order(analyzed_at: :desc).first
  end
end
