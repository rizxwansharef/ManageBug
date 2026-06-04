# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.persisted? # if the user is not logged in, return

    user_project_ids = user.projects.select(:id)

    if user.role == 'manager'
      can :manage, Project, manager_id: user.id
      can :read, Bug do |bug|
        bug.project.manager_id == user.id
      end
      cannot [:create, :update, :destroy], Bug



    elsif user.role == 'qa'
      can :read, Project do |project|
        project.users.include?(user)
      end

      can :create, Bug, project_id: user_project_ids
      can [:update, :destroy], Bug do |bug|
        bug.reporter_id == user.id
      end
      cannot [:update, :destroy], Bug do |bug|
        bug.reporter_id != user.id
      end
      cannot [:create, :update, :destroy], Project



    elsif user.role == 'developer'
      can :read, Project do |project|
        project.users.include?(user)
      end

      can :change_status, Bug, project_id: user_project_ids

      cannot [:create, :destroy], Bug
      cannot [:create, :update, :destroy], Project
    end
  end
end
