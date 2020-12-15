class RemovePromoteridFromAds < ActiveRecord::Migration[6.0]
  def change
    rename_column :ads , :promoter_id , :creator_id
  end
end
