module ActionAccess
  module ModelAdditions
    module ClassMethods
      # Add Action Access user related utilities to the current model.
      def add_access_utilities
        include ActionAccess::UserUtilities
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
