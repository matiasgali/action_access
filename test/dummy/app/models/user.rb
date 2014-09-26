class User < ActiveRecord::Base
  include ActionAccess::ModelAdditions
  add_access_utilities

  def clearance_level
    role
  end
end
