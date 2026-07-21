class ChatAnalysesController < ApplicationController
  def create
    @chama = Chama.find(params[:chama_id])
    @chat_analysis = ChatAnalysisService.new(@chama, chat_analysis_params[:source_text]).call

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "chat_analysis",
          partial: "chamas/chat_analysis",
          locals: { chama: @chama, chat_analysis: @chat_analysis }
        )
      end
      format.html { redirect_to chama_path(@chama), notice: "Group chat analyzed." }
    end
  rescue Faraday::Error, JSON::ParserError => error
    Rails.logger.error("Chat analysis failed: #{error.class}: #{error.message}")
    redirect_to chama_path(@chama), alert: "Could not analyze the chat. Please try again."
  end

  private

  def chat_analysis_params
    params.require(:chat_analysis).permit(:source_text)
  end
end
