class Tag < ApplicationRecord
  include Paginatable
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, uniqueness: true
end
