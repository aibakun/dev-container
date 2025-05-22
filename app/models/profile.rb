class Profile < ApplicationRecord
  belongs_to :user

  validates :biography, presence: true
end
