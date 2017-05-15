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
      #
      # == Parameters
      #
      # +clearance_levels+:: single clearance level (string or symbol) or list
      #   of them (list of parameters or array), either singular or plural.
      #   Accepts the special keyword +:all+ (every clearance level, even none).
      #
      # +permissions+:: controller action (string or symbol) or list of them (array).
      #   Accepts the special keyword +:all+ (every action in the controller).
      #
      #
      # == Example:
      #
      #   class ArticlesControler < ApplicationController
      #     let :admins, :all                           # admins can do anything
      #     let :editors, :reviewers, [:edit, :update]  # editors and reviewers can edit articles
      #     let :all, [:index, :show]                   # anyone can view articles
      #
      #     # ...
      #   end
      #
      def let(*clearance_levels, permissions)
        lock_access unless access_locked?
        keeper = ActionAccess::Keeper.instance
        clearance_levels = Array(clearance_levels).flatten
        clearance_levels.each { |c| keeper.let c, permissions, self }
      end
    end


    def self.included(base)
      base.extend ClassMethods
      base.helper_method :keeper if base.respond_to? :helper_method
    end


    private

      # Helper to access Keeper's instance.
      def keeper
        ActionAccess::Keeper.instance
      end

      # Current user's clearance levels (override to customize).
      def current_clearance_levels
        # Notify deprecation of `current_clearance_level` (singular)
        if defined? current_clearance_level
          ActiveSupport::Deprecation.warn \
            '[Action Access] The use of "current_clearance_level" '   +
            'is going to be deprecated in the next release, rename ' +
            'it to "current_clearance_levels" (plural).'
          return current_clearance_level
        end

        if defined?(current_user) and current_user.respond_to?(:clearance_levels)
          current_user.clearance_levels
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
        action = self.action_name
        clearance_levels = Array(current_clearance_levels)
        authorized = clearance_levels.any? { |c| keeper.lets? c, action, self.class }
        not_authorized! unless authorized
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
