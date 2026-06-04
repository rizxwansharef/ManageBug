class User < ApplicationRecord
  validates :name, presence: true
  has_many :project_assignments
  has_many :projects, through: :project_assignments
  has_many :reported_bugs, class_name: "Bug", foreign_key: "reporter_id"
  has_many :qa_assignments, class_name: "Bug", foreign_key: "assignee_qa_id"
  has_many :dev_assignments, class_name: "Bug", foreign_key: "assignee_dev_id"
  has_one_attached :profile_picture
  has_many :notifications, foreign_key: "recipient_id", dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
