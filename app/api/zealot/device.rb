module Zealot
  class Device < Grape::API
    resource :devices do
      desc I18n.t('grape.devices.update.description')
      params do
        requires :token, type: String, desc: I18n.t('grape.global.params.token'), in: :query
        requires :id, type: String, desc: I18n.t('grape.devices.update.params.id')
        requires :name, type: String, desc: I18n.t('grape.devices.update.body.name')
        optional :model, type: String, desc: I18n.t('grape.devices.update.body.model')
      end
      post :id do
        authenticate!

        device = Device.find_or_create_by(udid: params[:id])
        device.update(params.permit(:name, :model))
        device
      end
    end
  end
end
