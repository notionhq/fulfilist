class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # rescue_from CanCan::AccessDenied do |exception|
  #   flash[:alert] = "Access denied!"
  #   redirect_to root_url
  # end
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User) && session[:return_to]
        session[:return_to]
      else
        super
      end
  end
end
