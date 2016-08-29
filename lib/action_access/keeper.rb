module ActionAccess
  class Keeper
    include Singleton

    def initialize
      @rules = {}
    end

    def reload
      @rules = {}
    end

    # Set clearance to perform actions over a resource.
    # Clearance level and resource can be either plural or singular.
    #
    # == Examples:
    #
    #   let :user, :show, :profile
    #   let :user, :show, @profile
    #   let :user, :show, ProfilesController
    #   # Any user can can access 'profiles#show'.
    #
    #   let :admins, [:edit, :update], :articles, namespace: :admin
    #   let :admins, [:edit, :update], @admin_article
    #   let :admins, [:edit, :update], Admin::ArticlesController
    #   # Admins can access 'admin/articles#edit' and 'admin/articles#update'.
    #
    def let(clearance_level, actions, resource, options = {})
      clearance_level = clearance_level.to_s.singularize.to_sym
      actions = Array(actions).map(&:to_sym)
      controller = get_controller_name(resource, options)
      @rules[controller] ||= {}
      @rules[controller][clearance_level] ||= []
      @rules[controller][clearance_level] += actions
      @rules[controller][clearance_level].uniq!
      return nil
    end

    # Check if a given clearance level allows to perform an action on a resource.
    # Clearance level and resource can be either plural or singular.
    #
    # == Examples:
    #
    #   lets? :users, :create, :profiles
    #   lets? :users, :create, @profile
    #   lets? :users, :create, ProfilesController
    #   # True if users are allowed to access 'profiles#create'.
    #
    #   lets? :admin, :edit, :article, namespace: :admin
    #   lets? :admin, :edit, @admin_article
    #   lets? :admin, :edit, Admin::ArticlesController
    #   # True if any admin is allowed to access 'admin/articles#edit'.
    #
    def lets?(clearance_level, action, resource, options = {})
      clearance_level = clearance_level.to_s.singularize.to_sym
      action = action.to_sym
      controller = get_controller_name(resource, options)

      # Load the controller to ensure its rules are loaded (lazy loading rules).
      controller.constantize.new
      rules = @rules[controller]
      return false unless rules

      # Check rules
      Array(rules[:all]).include?(:all)               ||
      Array(rules[:all]).include?(action)             ||
      Array(rules[clearance_level]).include?(:all)    ||
      Array(rules[clearance_level]).include?(action)
    end


    private

      def get_controller_name(resource, options = {})
        # Assume a controller if given a class
        return resource.name if resource.is_a? Class

        # Assume a model instance if not a string or symbol
        unless resource.is_a?(String) || resource.is_a?(Symbol)
          resource = resource.class.name
        end

        # Build controller name
        path = options[:namespace].to_s.split(/::|\//).reject(&:blank?).map(&:camelize)
        path << resource.to_s.camelize.pluralize + 'Controller'
        controller = path.join('::')

        # Make sure that the controller exists.
        # Will throw a NameError exception if resource and/or namespace are wrong.
        controller.constantize

        # Return controller name
        return controller
      end
  end
end
