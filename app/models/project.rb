class Project < ApplicationRecord
    validates :name, presence: true
    validates :manager_id, presence: true
    has_many :project_assignments, dependent: :destroy
    has_many :users, through: :project_assignments
    has_many :bugs, dependent: :destroy
    belongs_to :manager, class_name: "User"
    has_one_attached :avatar
    validate :acceptable_image

  private

  def acceptable_image
    return unless avatar.attached?

    # Define allowed mime types
    acceptable_types = [ "image/jpeg", "image/png" ]

    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "must be a JPEG or PNG image")
    end
  end
end
