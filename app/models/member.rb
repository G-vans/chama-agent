class Member < ApplicationRecord
  belongs_to :chama
  has_many :contributions

  def total_paid
    contributions.where(status: "completed").sum(:amount).to_i
  end

  def months_since_joined
    ((Date.today - joined_at).to_i / 30.0).ceil
  end

  def expected_total
    (months_since_joined * chama.contribution_amount).to_i
  end

  def arrears
    [expected_total - total_paid, 0].max
  end

  def months_behind
    return 0 if arrears.zero?
    (arrears / chama.contribution_amount.to_i).ceil
  end

  def status
    arrears.zero? ? "up_to_date" : "behind"
  end
end