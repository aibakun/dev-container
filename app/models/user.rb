require 'digest'

class User < ApplicationRecord
  include Paginatable
  has_secure_password
  has_one :profile, dependent: :destroy
  has_one :api_token, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :purchase_histories, dependent: :destroy
  has_many :orders, dependent: :destroy

  enum occupation: { student: 0, employee: 10, self_employed: 20, unemployed: 30, other: 40 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 4 }, allow_blank: true
  validates :occupation, presence: true
end
