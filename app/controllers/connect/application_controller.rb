module Connect
  class ApplicationController < ::ApplicationController #ActionController::Base
    include Authentication
    include ControllerAdditions

    #rescue_from HttpError do |e|
    #  render status: e.status, nothing: true
    #end

    protect_from_forgery

    ActiveSupport.run_load_hooks :connect_controller, self
  end
end