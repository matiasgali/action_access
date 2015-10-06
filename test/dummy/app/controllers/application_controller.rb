class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Lock controllers by default
  lock_access


  private

    def current_clearance_levels
      session[:roles] || :guest
    end
end
