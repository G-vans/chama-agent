class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.string :name
      t.string :phone
      t.references :chama, null: false, foreign_key: true
      t.date :joined_at

      t.timestamps
    end
  end
end
