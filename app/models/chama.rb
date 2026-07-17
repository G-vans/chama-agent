class Chama < ApplicationRecord
  has_many :members
  has_many :agent_reports
end
