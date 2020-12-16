class Ad < ApplicationRecord
  has_one_attached :clip
  validates :title, presence: true
  validates :description, presence: true
  validates :clip, presence: true
  # belongs_to :user
  has_many :ad_requests
  has_many :ad_views


end
