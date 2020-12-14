class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  validates :name, presence: true
  validates :validity, presence: true
  validates :user_type, presence: true
  has_many :followers
  has_one :wallet


end
