class TemplateController < ApplicationController
  attr_accessor :record
  attr_accessor :presenter

  def edit
    self.presenter = presenter
  end

  def update
    self.record = load_record
    self.record.attributes = permitted_params

    if self.record.save
      redirect_to [:edit, :template]
    else
      render 'edit'
    end
  end

  def data
    name = params[:name]
    template = presenter.templates.select do |template|
      template.name == name
    end.first

    render json: template.data
  end

  private

  def presenter
    @presenter ||= Template::EditPresenter.new
  end

  def load_record
    presenter.record
  end

  def permitted_params
    return {} unless params[:setting]
    params.require(:setting).permit(:value)
  end
end
