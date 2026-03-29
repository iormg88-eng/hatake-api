class CreateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :fields do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, null: false
      t.string :crop

      t.timestamps
    end
  end
end
