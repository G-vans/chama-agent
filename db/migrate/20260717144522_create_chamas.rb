class CreateChamas < ActiveRecord::Migration[8.1]
  def change
    create_table :chamas do |t|
      t.string :name
      t.decimal :contribution_amount
      t.string :frequency

      t.timestamps
    end
  end
end
