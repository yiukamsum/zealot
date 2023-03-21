# frozen_string_literal: true

module Zealot::Helpers::UploadApp
  def create_or_update_release
    ActiveRecord::Base.transaction do
      new_record? ? create_new_app_build : create_build_from_exist_app
    end
  end

  # 创建 App 并创建新版本
  def create_new_app_build
    create_release with_channel and_scheme and_app
  end

  # 使用现有 App 创建新版本
  def create_build_from_exist_app
    message = t('releases.messages.errors.bundle_id_not_matched', got: app_parser.bundle_id,
      expect: @channel.bundle_id)
    raise TypeError, message unless @channel.bundle_id_matched? app_parser.bundle_id

    create_release with_updated_channel
  end

  def new_record?
    @channel.blank?
  end

  def perform_app_web_hook_job
    @channel.perform_web_hook('upload_events', @user.id)
  end

  def perform_teardown_job
    @release.perform_teardown_job(@user.id)
  end

  ###########################
  # new build methods
  ###########################
  def with_updated_channel
    @channel.update! channel_params
    @channel
  end

  def create_release(channel)
    @release = channel.releases.upload_file(release_params, app_parser, 'api')
    @release.save!
  end

  def with_channel(scheme)
    @channel = scheme.channels.find_or_create_by channel_params do |channel|
      channel.name = app_parser.os
      channel.device_type = app_parser.os
    end
  end

  def and_scheme(app)
    name = parse_scheme_name
    app.schemes.find_or_create_by(name: name)
  end

  def and_app
    permitted = params.clone
    permitted[:name] ||= app_parser.name

    App.find_or_create_by permitted do |app|
      app.users << @user
    end
  end

  def parse_scheme_name
    default_name = t('api.apps.upload.create.adhoc')
    return default_name unless app_parser.os == AppInfo::Platform::IOS

    t("api.apps.upload.create.#{app_parser.release_type.downcase}", default: default_name)
  end

  RELEASE_PARAMS = %i[
    file release_type source branch git_commit
    ci_url changelog devices custom_fields
  ]
  def release_params
    params.keey_if { |k, _| RELEASE_PARAMS.include?(k) }
  end

  CHANNEL_PARAMS = %i[slug password git_url]

  def channel_params
    params.keey_if { |k, _| CHANNEL_PARAMS.include?(k) }
  end

  def app_parser
    @app_parser ||= AppInfo.parse(params[:file].path)
  end
end
