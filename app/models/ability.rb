# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.persisted? # if the user is not logged in, return

    if [ "qa", "developer" ].include?(user.role)
      can :read, Project do |project|
        project.users.include?(user)
      end
      can :read, Bug do |bug|
        bug.project.users.include?(user)
      end
      cannot [ :create, :update, :destroy, :edit ], Project
    end

    if user.role == "manager"
      can :manage, Project, manager_id: user.id
      can :read, Bug do |bug|
        bug.project.manager_id == user.id
      end
      cannot [ :create, :update, :destroy ], Bug
      cannot [ :change_status ], Bug

    elsif user.role == "qa"
      can :create, Bug, project_id: user.project_ids
      can :change_status, Bug do |bug|
        bug.assignee_qa_id == user.id
      end

      can [ :update, :destroy ], Bug do |bug|
        bug.reporter_id == user.id
      end
      cannot [ :update, :destroy ], Bug do |bug|
        bug.reporter_id != user.id
      end

    elsif user.role == "developer"
      can [ :update, :change_status ], Bug do |bug|
        bug.assignee_dev_id == user.id
      end

      cannot [ :create, :destroy ], Bug
    end
  end
end
