# frozen_string_literal: true

module Zealot
  class Engine < Grape::API
    prefix 'beta'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    helpers do
      def channel
        @channel ||= Channel.find_by(key: params[:channel_key])
      end

      def determine_channel!
        error!('404 Not found channel', 404) unless channel
      end

      def current_user
        @current_user ||= User.find_by(token: params[:token])
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    mount App
    mount DebugFile

    add_swagger_documentation(
      doc_version: 'v1',
      info: {
        title: I18n.t('grape.title'),
        description: I18n.t('grape.description'),
        license: 'MIT',
        license_url: 'https://github.com/tryzealot/zealot/blob/develop/LICENSE'
      },
      tags:[
        { name: 'apps', description: I18n.t('grape.tags.apps') },
        { name: 'debug_files', description: I18n.t('grape.tags.debug_files') },
        { name: 'devices', description: I18n.t('grape.tags.devices') },
      ],
      mount_path: '/swagger.v1',
      security_definitions: {
        token: {
          type: "apiKey",
          name: "token",
          in: "query"
        }
      }
    )

    mount Device
  end
end
