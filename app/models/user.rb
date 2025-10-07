class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :projects, dependent: :destroy

  alias_attribute :email, :email_address

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
