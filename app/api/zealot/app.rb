# frozen_string_literal: true

module Zealot
  class App < Grape::API
    helpers Helpers::Channel, Helpers::Params

    resource :apps do
      desc I18n.t('grape.apps.upload.description') do
        security [token: []]
        success API::UploadAppSerializer
        failure [
          [401, I18n.t('grape.global.errors.unauthorized'), Entities::Error],
          [404, I18n.t('grape.global.errors.not_found_channel'), Entities::Error]
        ]
      end

      params do
        requires :channel_key, type: String, desc: I18n.t('grape.global.params.channel_key')
        requires :file, type: File, desc: I18n.t('grape.apps.upload.params.file')
        optional :bundle_id, type: String, desc: I18n.t('grape.apps.upload.params.bundle_id')
        optional :release_version, type: String, desc: I18n.t('grape.apps.upload.params.release_version')
        optional :build_version, type: String, desc: I18n.t('grape.apps.upload.params.build_version')
        optional :password, type: String, desc: I18n.t('grape.apps.upload.params.password')
        optional :release_type, type: String, desc: I18n.t('grape.apps.upload.params.release_type')
        optional :source, type: String, default: 'api', desc: I18n.t('grape.apps.upload.params.source')
        optional :changelog, type: String, desc: I18n.t('grape.apps.upload.params.changelog')
        optional :branch, type: String, desc: I18n.t('grape.apps.upload.params.branch')
        optional :git_commit, type: String, desc: I18n.t('grape.apps.upload.params.git_commit')
        optional :ci_url, type: String, desc: I18n.t('grape.apps.upload.params.ci_url')
      end
      post :upload do
        authenticate!
        determine_channel!

        create_or_update_release
        perform_teardown_job
        perform_app_web_hook_job

        render json: @release,
          serializer: API::UploadAppSerializer,
          status: :created
      end

      desc I18n.t('grape.apps.latest.description') do
        success ::API::LatestAppSerializer
      end
      params do
        requires :channel_key, type: String, desc: I18n.t('grape.global.params.channel_key')
        requires :bundle_id, type: String, desc: I18n.t('grape.apps.latest.params.bundle_id')
        requires :release_version, type: String, desc: I18n.t('grape.apps.latest.params.release_version')
        requires :build_version, type: String, desc: I18n.t('grape.apps.latest.params.build_version')
      end
      get :latest do
        determine_channel!

        render channel, serializer: ::API::LatestAppSerializer,
          bundle_id: params[:bundle_id],
          release_version: params[:release_version],
          build_version: params[:build_version]
      end

      desc I18n.t('grape.apps.versions.description') do
        success ::API::AppVersionsSerializer
      end
      params do
        requires :channel_key, type: String, desc: I18n.t('grape.global.params.channel_key')
        optional :per_page, type: Integer, desc: I18n.t('grape.global.params.per_page'), default: 10
        optional :page, type: Integer, desc: I18n.t('grape.global.params.page'), default: 1
      end
      get :versions do
        determine_channel!

        render channel, serializer: ::API::AppVersionsSerializer,
          bundle_id: params[:bundle_id],
          release_version: params[:release_version],
          build_version: params[:build_version]
      end

      desc I18n.t('grape.apps.version_exist.description') do
        success ::API::AppVersionsSerializer
      end
      params do
        requires :channel_key, type: String, desc: I18n.t('grape.global.params.channel_key')
        optional :bundle_id, type: String, desc: I18n.t('grape.apps.version_exist.params.bundle_id')
        optional :git_commit, type: String, desc: I18n.t('grape.apps.version_exist.params.git_commit')
        optional :release_version, type: String, desc: I18n.t('grape.apps.version_exist.params.release_version')
        optional :build_version, type: String, desc: I18n.t('grape.apps.version_exist.params.build_version')
      end
      get :version_exist do
        determine_channel!
        determine_channel_params!

        where_params = params.merge(channel_id: channel&.id)
        raise ActiveRecord::RecordNotFound, I18n.t('api.apps.version_exist.show.not_found') unless Release.exists?(where_params)

        Release.find_by(where_params)
      end

      desc I18n.t('grape.apps.list.description'), is_array: true do
        security [token: []]
        success [::API::AppSerializer]
      end
      params do
        use :pagination
      end
      get do
        authenticate!

        apps = ::App.page(params[:page]).per(params[:per_page])
        render apps, serializer: ::API::AppSerializer, include: 'schemes.channels'
      end

      desc I18n.t('grape.apps.detail.description') do
        security [token: []]
        success ::API::AppSerializer
      end
      params do
        requires :id, type: String, desc: I18n.t('grape.apps.detail.params.id')
      end
      get '{id}' do
        authenticate!

        app = ::App.find(params[:id])
        render app, serializer: ::API::AppSerializer, include: 'schemes.channels'
      end
    end
  end
end
