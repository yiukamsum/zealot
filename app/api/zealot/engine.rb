module Zealot
  class Engine < Grape::API
    prefix 'beta'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    helpers do
      def channel_key
        @channel_key ||= Channel.find_by(key: params[:channel_key])
      end

      def current_user
        @current_user ||= User.find_by(token: params[:token])
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    mount App
    mount Device

    add_swagger_documentation(
      info: { title: I18n.t('grape.title') },
      doc_version: '1.5',
      token_owner: 'user_token'
    )
  end
end
