class Chama < ApplicationRecord
  has_many :members
  has_many :agent_reports
  has_many :chat_analyses
end
