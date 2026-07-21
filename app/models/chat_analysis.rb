class ChatAnalysis < ApplicationRecord
  belongs_to :chama

  validates :source_text, :content, :analyzed_at, presence: true

  def parsed_content
    JSON.parse(content)
  end
end
