class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :reporter, class_name: "User"
  belongs_to :assignee_qa, class_name: "User"
  belongs_to :assignee_dev, class_name: "User"
  has_one_attached :screenshot


  validates :project_id, presence: true
  validates :assignee_dev_id, presence: true
  validates :assignee_qa_id, presence: true
  validates :title, presence: true, uniqueness: { scope: :project_id, message: "must be unique within the same project" }
  validates :description, presence: true
  validates :bug_type, presence: true, inclusion: { in: %w[bug feature] }
  validates :status, presence: true
  validate :acceptable_image

  private

  def acceptable_image
    return unless screenshot.attached?

    acceptable_types = [ "image/jpeg", "image/png" ]
    unless acceptable_types.include?(screenshot.content_type)
      errors.add(:screenshot, "must be a JPEG or PNG image")
    end
  end
end
