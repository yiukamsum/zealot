# frozen_string_literal: true

class API::Jenkins::StatusController < API::JenkinsController
  def show
    render json: project_status
  end
end
