# frozen_string_literal: true

class API::Apps::LatestController < Api::BaseController
  before_action :validate_channel_key

  # GET /api/apps/latest
  def show
    headers['Last-Modified'] = Time.now.httpdate

    render json: @channel,
           serializer: API::LatestAppSerializer,
           bundle_id: params[:bundle_id],
           release_version: params[:release_version],
           build_version: params[:build_version]
  end
end
