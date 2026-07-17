# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

chama = Chama.create!(name: "Demo Chama", contribution_amount: 5000, frequency: "monthly")

[
  ["Jane Doe", "254712345678"],
  ["Peter Kariuki", "254722334455"],
  ["Mary Wanjiku", "254733445566"],
  ["Samuel Otieno", "254744556677"],
  ["Grace Njeri", "254755667788"]
].each do |name, phone|
  Member.create!(name: name, phone: phone, chama: chama, joined_at: Date.today - rand(30..90))
end

puts "Seeded: #{Chama.count} chama, #{Member.count} members"