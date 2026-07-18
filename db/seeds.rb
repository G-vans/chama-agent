# This file should ensure the existence of records required to run the application in every environment
# (production, development, test). The code here should be idempotent so that it can be executed at
# any point in every environment.
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

chama = Chama.create!(
  name: "Demo Chama",
  contribution_amount: 5000,
  frequency: "monthly"
)

# All members joined 90 days ago = 3 months expected contributions each
members_data = [
  { name: "Jane Doe",      phone: "254708374149", months_paid: 3 },  # Up to date
  { name: "Peter Kariuki", phone: "254722334455", months_paid: 3 },  # Up to date
  { name: "Mary Wanjiku",  phone: "254733445566", months_paid: 2 },  # 1 month behind (KES 5,000)
  { name: "Samuel Otieno", phone: "254744556677", months_paid: 1 },  # 2 months behind (KES 10,000)
  { name: "Grace Njeri",   phone: "254755667788", months_paid: 0 }   # 3 months behind (KES 15,000)
]

members_data.each do |data|
  member = Member.create!(
    name: data[:name],
    phone: data[:phone],
    chama: chama,
    joined_at: 90.days.ago.to_date
  )

  data[:months_paid].times do |m|
    Contribution.create!(
      member: member,
      amount: chama.contribution_amount,
      mpesa_receipt: "DEMO#{SecureRandom.hex(4).upcase}",
      paid_at: (m + 1).months.ago,
      status: "completed"
    )
  end
end

puts "Seeded: #{Chama.count} chama, #{Member.count} members, #{Contribution.count} contributions"