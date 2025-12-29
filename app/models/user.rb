class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :rememberable,
         :jwt_authenticatable, jwt_revocation_strategy: self
  
  has_many :user_movies, dependent: :destroy
  has_many :movies, through: :user_movies
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  def jwt_payload
    super
  end
end
