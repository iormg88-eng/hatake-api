class CreateFieldLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :field_logs do |t|
      t.references :field, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "good"
      t.string :tags,   null: false, default: [], array: true
      t.string :memo

      t.timestamps
    end
  end
end
