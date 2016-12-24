class UserAbility
  include CanCan::Ability

  def initialize(user)

    if user.present?

      can :manage, user

      # ADMIN
      if user.roles.include?('admin')
        can :manage, User
      end

      # MANAGER
      if user.roles.include?('manager')
      end

    end
  end
end
