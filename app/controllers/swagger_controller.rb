# frozen_string_literal: true

class SwaggerController < ApplicationController
  def index
    @title = t('grape.title')
  end
end
