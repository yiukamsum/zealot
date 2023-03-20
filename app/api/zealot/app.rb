module Zealot
  class App < Grape::API
    resource :apps do
      desc I18n.t('grape.apps.list.description')
      params do
        requires :token, type: String, desc: I18n.t('grape.global.params.token')
        optional :per_page, type: Integer, desc: I18n.t('grape.global.params.per_page'), default: 10
        optional :page, type: Integer, desc: I18n.t('grape.global.params.page'), default: 1
      end
      get do
        authenticate!

        apps = ::App.all
        render apps, serializer: ::API::AppSerializer, include: 'schemes.channels'
      end

      desc I18n.t('grape.apps.detail.description')
      get :id do
        authenticate!

        app = ::App.find(params[:id])
        render app, serializer: ::API::AppSerializer, include: 'schemes.channels'
      end
    end
  end
end
