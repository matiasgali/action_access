class User < ActiveRecord::Base
  add_access_utilities

  def clearance_level
    role
  end
end
