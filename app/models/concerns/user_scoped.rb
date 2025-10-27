module UserScoped
  extend ActiveSupport::Concern

  included do
    # The user should control its own project.
    def owned_by?(user)
      case self
      when Project
        self.user_id == user.id
      when Act, Character, Location, Idea
        project.user_id == user.id
      when Sequence
        project.user_id == user.id
      when Scene
        project.user_id == user.id
      else
        false
      end
    end
  end

  class_methods do
    def for_user(user)
      case name
      when "Project"
        where(user: user)
      when "Act", "Character", "Location", "Idea"
        joins(:project).where(projects: { user: user })
      when "Sequence"
        where(project: user.projects)
      when "Scene"
        where(project: user.projects)
      else
        none
      end
    end
  end
end
