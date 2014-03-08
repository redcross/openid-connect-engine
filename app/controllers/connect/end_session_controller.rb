module Connect
  class EndSessionController < ApplicationController
    def logout
      unauthenticate!
      redirect_to next_url
    end

    protected

    def id_token
      return nil unless token = params[:id_token_hint]

      @id_token ||= IdToken.decode token
    end

    def next_url
      params[:post_logout_redirect_uri] || main_app.root_url
    end
  end
end