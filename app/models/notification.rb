class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  validates :message, presence: true
end