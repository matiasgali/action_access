module ActionAccess
  module UserUtilities
    # Check if the user is authorized to perform a given action.
    #
    # Resource can be either plural or singular.
    #
    # == Examples:
    #   user.can? :show, :articles
    #   user.can? :show, @article
    #   user.can? :show, ArticlesController
    #   # True if the user's clearance level allows to access 'articles#show'
    #
    #   user.can? :edit, :articles, namespace: :admin
    #   user.can? :edit, @admin_article
    #   user.can? :edit, Admin::ArticlesController
    #   # True if the user's clearance level allows to access 'admin/articles#edit'
    #
    def can?(action, resource, options = {})
      keeper = ActionAccess::Keeper.instance
      keeper.lets? clearance_level, action, resource, options
    end


    private

      # Accessor for the user's clearance level.
      #
      # Must be overridden to set the proper clearance level.
      #
      # == Example:
      #   def clearance_level
      #     role.name
      #   end
      #
      def clearance_level
        :guest
      end
  end
end
