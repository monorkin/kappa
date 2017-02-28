class TypeController < ApplicationController
  attr_accessor :record

  def edit
    @presenter = Type::EditPresenter.new
  end
end
