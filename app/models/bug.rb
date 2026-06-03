class Bug < ApplicationRecord
  belongs_to :project 
  belongs_to :reporter, class_name: "User"
  belongs_to :assignee_qa, class_name: "User"
  belongs_to :assignee_dev, class_name: "User"  
  has_one_attached :screenshot
end