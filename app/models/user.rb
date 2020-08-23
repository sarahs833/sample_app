class User < ApplicationRecord

  has_many :microposts
  has_many :microposts, dependent: :destroy
  #we explicit says that our foreign_key is follower_id (ex: has_many user_posts, foreign_key: user_id)
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  #find the people's i'm following through active_relationships, followed_id. (ex has_many: posts, thought: user_posts)
  has_many :following, through: :active_relationships, source: :followed #here we write followed to find the followed_id in the join table
  #the other side of the has_many
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token,:activation_token,:reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum:50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                           format: { with: VALID_EMAIL_REGEX},
                           uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end

  # 关注另一个用户
  def follow(other_user)
    following << other_user
  end
  # 取消关注另一个用户
  def unfollow(other_user)
    following.delete(other_user)
  end
  # 如果当前用户关注了指定的用户，返回 true
  def following?(other_user)
    following.include?(other_user)
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  #use to find the raw remember_token if match with db bcryted
  def authenticated?(attribute,token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    #user.remember_digest == remember_token?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def remember
    self.remember_token = User.new_token #create a random number
    update_attribute(:remember_digest, User.digest(remember_token)) #pass this random number to be bcrypt to the db(like password)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  private
# 把电子邮件地址转换成小写
  def downcase_email
    self.email = email.downcase
  end
  # 创建并赋值激活令牌和摘要
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end




end
