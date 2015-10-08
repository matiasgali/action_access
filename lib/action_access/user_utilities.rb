module ActionAccess
  module UserUtilities
    # Check if the user is authorized to perform a given action.
    # Resource can be either plural or singular.
    #
    # == Examples:
    #
    #   user.can? :show, :articles
    #   user.can? :show, @article
    #   user.can? :show, ArticlesController
    #   # True if any of the user's clearance levels allows to access 'articles#show'
    #
    #   user.can? :edit, :articles, namespace: :admin
    #   user.can? :edit, @admin_article
    #   user.can? :edit, Admin::ArticlesController
    #   # True if any of the user's clearance levels allows to access 'admin/articles#edit'
    #
    def can?(action, resource, options = {})
      keeper = ActionAccess::Keeper.instance
      clearance_levels = Array(clearance_levels())
      clearance_levels.any? { |c| keeper.lets? c, action, resource, options }
    end


    # Accessor for the user's clearance levels.
    #
    # Must be *overridden* to set the proper clearance levels.
    #
    # == Examples:
    #
    #   # Single clearance level (returns string)
    #   def clearance_levels
    #     role.name
    #   end
    #
    #   # Multiple clearance levels (returns array)
    #   def clearance_levels
    #     roles.pluck(:name)
    #   end
    #
    def clearance_levels
      # Notify deprecation of `clearance_level` (singular)
      if defined? clearance_level
        ActiveSupport::Deprecation.warn \
          '[Action Access] The use of "clearance_level" in models ' +
          'is going to be deprecated in the next release, rename ' +
          'it to "clearance_levels" (plural).'
        return clearance_level
      end

      :guest
    end
  end
end
