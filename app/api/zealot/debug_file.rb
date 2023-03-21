# frozen_string_literal: true

module Zealot
  class DebugFile < Grape::API
    helpers Helpers::Channel, Helpers::Params

    resource :debug_files do
      desc I18n.t('grape.apps.upload.description') do
        security [token: []]
        success API::DebugFileSerializer
        failure [
          [400, I18n.t('grape.global.errors.bad_request'), Entities::Error],
          [401, I18n.t('grape.global.errors.unauthorized'), Entities::Error],
          [404, I18n.t('grape.global.errors.not_found_channel'), Entities::Error]
        ]
      end

      params do
        requires :channel_key, type: String, desc: I18n.t('grape.global.params.channel_key')
        requires :file, type: File, desc: I18n.t('grape.debug_files.upload.params.file')
        optional :release_version, type: String, desc: I18n.t('grape.debug_files.upload.params.release_version')
        optional :build_version, type: String, desc: I18n.t('grape.debug_files.upload.params.build_version')
      end
      post :upload do
        authenticate!
        determine_channel!

        debug_file = DebugFile.new(params)
        debug_file.app = channel.app
        debug_file.device_type = channel.device_type
        if debug_file.save!
          DebugFileTeardownJob.perform_now(@debug_file)
          render json: debug_file, serializer: API::DebugFileSerializer, status: :created
        else
          render json: debug_file.errors, status: :bad_request
        end
      end

      desc I18n.t('grape.debug_files.list.description'), is_array: true do
        security [token: []]
        success [::API::DebugFileSerializer]
      end
      params do
        use :pagination
      end
      get do
        authenticate!

        debug_files = ::DebugFile.where(app: channel.app)
          .where(device_type: channel.device_type)
          .page(params[:page].to_i)
          .per(params[:per_page].to_i)
          .order(id: :desc)

        render debug_files, each_serializer: ::API::DebugFileSerializer
      end

      desc I18n.t('grape.debug_files.detail.description') do
        security [token: []]
        success ::API::DebugFileSerializer
      end
      params do
        requires :id, type: String, desc: I18n.t('grape.debug_files.detail.params.id')
      end
      get '{id}' do
        authenticate!

        debug_file = ::DebugFile.find(params[:id])
        render debug_file, serializer: ::API::DebugFileSerializer
      end

      desc I18n.t('grape.debug_files.update.description') do
        security [token: []]
        success ::API::DebugFileSerializer
      end
      params do
        requires :id, type: String, desc: I18n.t('grape.debug_files.update.params.id')
      end
      put '{id}' do
        authenticate!

        debug_file = ::DebugFile.find(params[:id])
        render debug_file, serializer: ::API::DebugFileSerializer
      end

      desc I18n.t('grape.debug_files.destroy.description') do
        security [token: []]
        success ::API::DebugFileSerializer
      end
      params do
        requires :id, type: String, desc: I18n.t('grape.debug_files.destroy.params.id')
      end
      delete '{id}' do
        authenticate!

        debug_file = ::DebugFile.find(params[:id])
        render debug_file, serializer: ::API::DebugFileSerializer
      end
    end
  end
end
