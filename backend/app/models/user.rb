class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :recoverable（メールでのパスワード再設定）は入れない。mailer を設定しておらず、
  # 再設定の申請は 500 になっていた。admin のパスワード変更は rails console で行う。
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  enum :role, { guest: 0, admin: 1 }, prefix: true

  validates :role, presence: true, inclusion: { in: roles.keys }
end
