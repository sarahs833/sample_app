class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum:50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                           format: { with: VALID_EMAIL_REGEX},
                           uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  #use to find the raw remember_token if match with db bcryted
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    #user.remember_digest == remember_token?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def remember
    self.remember_token = User.new_token #create a random number
    update_attribute(:remember_digest, User.digest(remember_token)) #pass this random number to be bcrypt to the db(like password)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end



end
