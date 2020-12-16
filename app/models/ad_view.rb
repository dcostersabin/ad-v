class AdView < ApplicationRecord
  belongs_to :ad
  validates :promoter_id, presence: true
  validates :user_id, presence: true
  validates :ad_id, presence: true
  # validates :payable, presence: true
end
