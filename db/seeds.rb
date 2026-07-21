# This file should ensure the existence of records required to run the application in every environment
# (production, development, test). The code here should be idempotent so that it can be executed at
# any point in every environment.
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

chama = Chama.find_or_initialize_by(name: "Demo Chama")
chama.update!(contribution_amount: 5000, frequency: "monthly")

# Reset this chama's generated data so every rehearsal starts from the same story.
AgentReport.where(chama: chama).delete_all
Contribution.where(member_id: chama.member_ids).delete_all
Member.where(chama: chama).delete_all

# At 89 days, Member#months_since_joined consistently expects three payments.
members_data = [
  { name: "Jane Doe",      phone: "254708374149", months_paid: 2 },  # Demo target: KES 5,000 behind
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
    joined_at: 89.days.ago.to_date
  )

  data[:months_paid].times do |m|
    Contribution.create!(
      member: member,
      amount: chama.contribution_amount,
      mpesa_receipt: "SEED-#{member.name.parameterize.upcase}-#{m + 1}",
      paid_at: (m + 1).months.ago,
      status: "completed"
    )
  end
end

puts "Seeded Demo Chama: #{chama.members.count} members, #{Contribution.where(member: chama.members).count} contributions"
