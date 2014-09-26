module ActionAccess
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << ActionAccess

    initializer 'action_access.controller_additions' do
      # Extend ActionController::Base
      ActiveSupport.on_load :action_controller do
        include ControllerAdditions
      end
    end

    initializer 'action_access.model_additions' do
      # Extend ActiveRecord::Base
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end
  end
end
