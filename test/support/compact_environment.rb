# Minimal fake environment
module Admin; end
class PostsController; end
class Admin::PostsController; end

# Accessor for the Keeper's instance
def keeper
  ActionAccess::Keeper.instance
end
