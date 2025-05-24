class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {:guest=>0, :admin=>1}, prefix: true

  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :email, presence: true
  validates :encrypted_password, presence: true
end
