class CreateAdViews < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_views do |t|
      t.integer :user_id
      t.integer :ad_id
      t.boolean :payable
      t.integer :promoter_id

      t.timestamps
    end
  end
end
