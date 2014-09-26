require 'singleton'
require 'action_access/version'
require 'action_access/railtie'

module ActionAccess
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Keeper
    autoload :ControllerAdditions
    autoload :ModelAdditions
    autoload :UserUtilities
  end
end
