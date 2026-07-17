class CreateAgentReports < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_reports do |t|
      t.references :chama, null: false, foreign_key: true
      t.text :content
      t.datetime :generated_at

      t.timestamps
    end
  end
end
