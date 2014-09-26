module ActionAccess
  module ControllerAdditions
    module ClassMethods
      # Lock actions by default, they won't be accessible unless authorized.
      # It takes the same options as filter callbacks.
      def lock_access(options = {})
        before_action :validate_access!, options
      end

      # Is this controller locked?
      def access_locked?
        filters = _process_action_callbacks.collect(&:filter)
        :validate_access!.in? filters
      end

      # Set an access rule for the current controller.
      # It will automatically lock the controller if it wasn't already.
      #
      # == Example:
      # Add the following to ArticlesController to allow admins to edit articles.
      #   let :admin, [:edit, :update]
      #
      def let(clearance_level, permissions)
        lock_access unless access_locked?
        keeper = ActionAccess::Keeper.instance
        keeper.let clearance_level, permissions, self
      end
    end


    def self.included(base)
      base.extend ClassMethods
      base.helper_method :keeper
    end


    private

      # Helper to access Keeper's instance.
      def keeper
        ActionAccess::Keeper.instance
      end

      # Clearance level of the current user (override to customize).
      def current_clearance_level
        if defined? current_user and current_user.respond_to?(:clearance_level)
          current_user.clearance_level.to_s.to_sym
        else
          :guest
        end
      end

      # Default path to redirect any non authorized access (override to customize).
      def unauthorized_access_redirection_path
        root_path
      end

      # Validate access to the current route.
      def validate_access!
        clearance_level = current_clearance_level
        action = self.action_name
        not_authorized! unless keeper.lets? clearance_level, action, self.class
      end

      # Redirect if not authorized.
      # May be used inside action methods for finer control.
      def not_authorized!(*args)
        options = args.extract_options!
        message = options[:message] ||
          I18n.t('action_access.redirection_message', default: 'Not authorized.')
        path = options[:path] || unauthorized_access_redirection_path
        redirect_to path, alert: message
      end
  end
end
