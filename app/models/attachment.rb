class Attachment < ApplicationRecord
  validates :path, presence: true
end
