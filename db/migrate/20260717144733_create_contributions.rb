class CreateContributions < ActiveRecord::Migration[8.1]
  def change
    create_table :contributions do |t|
      t.references :member, null: false, foreign_key: true
      t.decimal :amount
      t.string :mpesa_receipt
      t.datetime :paid_at
      t.string :status

      t.timestamps
    end
  end
end
