class CreateAdRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_requests do |t|
      t.integer :promoter_id
      t.integer :ad_id
      t.boolean :accepted
      t.boolean :paid

      t.timestamps
    end
  end
end
