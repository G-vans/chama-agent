class Member < ApplicationRecord
  belongs_to :chama
  has_many :contributions
end
