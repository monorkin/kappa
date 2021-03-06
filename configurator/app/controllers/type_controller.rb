class TypeController < ApplicationController
  attr_accessor :record
  attr_accessor :presenter

  def edit
    self.presenter = Type::EditPresenter.new
  end

  def update
    self.record = load_record
    self.record.attributes = permitted_params

    if self.record.save
      redirect_to [:edit, :type]
    else
      render 'edit'
    end
  end

  private

  def presenter
    Type::EditPresenter.new
  end

  def load_record
    presenter.record
  end

  def permitted_params
    return {} unless params[:setting]
    params.require(:setting).permit(:value)
  end
end
