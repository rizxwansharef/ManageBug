class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
  has_many :project_assignments
  has_many :projects, through: :project_assignments
  has_many :reported_bugs, class_name: "Bug", foreign_key: "reporter_id"
  has_many :qa_assignments, class_name: "Bug", foreign_key: "assignee_qa_id"
  has_many :dev_assignments, class_name: "Bug", foreign_key: "assignee_dev_id"
  has_many :notifications, foreign_key: "recipient_id", dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
  has_one_attached :profile_picture
  validate :acceptable_image
  
  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false },
            format: { 
              with: /\A[^@\s]+@[^@\s]+\.com\z/, 
              message: "must contain '@' and end with '.com'" 
            }
  validates :password, 
            presence: true, 
            on: :create
  validates :password, 
            presence: true, 
            length: { minimum: 8 }, 
            format: { 
              with: /\A(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}\z/, 
              message: "must include at least one uppercase letter and one special character" 
            },
            if: -> { password.present? }


  private

  def acceptable_image
    return unless profile_picture.attached?

    # Define allowed mime types
    acceptable_types = [ "image/jpeg", "image/png" ]

    unless acceptable_types.include?(profile_picture.content_type)
      errors.add(:profile_picture, "must be a JPEG or PNG image")
    end
  end
end
