class User < ActiveRecord::Base
  add_access_utilities

  def clearance_levels
    roles.split(',')
  end
end
