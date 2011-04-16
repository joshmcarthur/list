module AccessControl
  
  module AccessControl::PublicAccess
    def can_access?(object, user)
      return true
    end
  end

  module AuthenticatedAccess
    def can_access?(object, user)
      return user.is_a?(User) && user.valid?
    end
  end

  module RestrictedAccess
    def can_access?(object, user)
      return object && object.permitted_users.include?(user)
    end
  end

  ACCESS_TYPES = {1 => PublicAccess, 2 => AuthenticatedAccess, 3 => RestrictedAccess}
end
