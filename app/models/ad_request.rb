class AdRequest < ApplicationRecord
  validates :promoter_id, presence: true
  validates :ad_id, presence: true
  belongs_to :ad
end
