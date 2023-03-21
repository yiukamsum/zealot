# frozen_string_literal: true

class Zealot::Entities::Error < Grape::Entity
  expose :error, documentation: { type: "String", desc: I18n.t('grape.global.params.error') }
end
