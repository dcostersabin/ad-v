class CreateAds < ActiveRecord::Migration[6.0]
  def change
    create_table :ads do |t|
      t.integer :promoter_id
      t.string :title
      t.text :description
      t.boolean :validity

      t.timestamps
    end
  end
end
