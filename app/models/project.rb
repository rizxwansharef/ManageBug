class Project < ApplicationRecord
    has_many :project_assignments, dependent: :destroy
    has_many :users, through: :project_assignments
    has_many :bugs, dependent: :destroy
    belongs_to :manager, class_name: "User"
    has_one_attached :avatar

end