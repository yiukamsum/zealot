# frozen_string_literal: true

class Api::SwaggerController < Api::BaseController

  # GET /api/apps
  def index
    render json: []
  end
end
