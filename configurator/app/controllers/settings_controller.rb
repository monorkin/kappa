class SettingsController < ApplicationController
  def index
    @settings = scope
  end

  def edit
    @setting = load_setting
  end

  def update
    @setting = load_setting
    @setting.attributes = permitted_params
    if @setting.save
      redirect_to [:edit, @setting]
    else
      render 'edit'
    end
  end

  private

  def permitted_params
    return {} unless params[:setting]
    params.require(:setting).permit(:value)
  end

  def load_setting
    scope.find(params[:id])
  end

  def scope
    Setting.all
  end
end
