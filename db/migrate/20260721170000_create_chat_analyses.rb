class CreateChatAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_analyses do |t|
      t.references :chama, null: false, foreign_key: true
      t.text :source_text, null: false
      t.text :content, null: false
      t.datetime :analyzed_at, null: false

      t.timestamps
    end
  end
end
