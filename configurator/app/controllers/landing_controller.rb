class LandingController < ApplicationController
  def show
    redirect_to [:edit, :template]
  end
end
