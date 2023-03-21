# frozen_string_literal: true

module Zealot::Helpers::Params
  extend ::Grape::API::Helpers

  params :pagination do
    optional :per_page, type: Integer, desc: I18n.t('grape.global.params.per_page'), default: 10
    optional :page, type: Integer, desc: I18n.t('grape.global.params.page'), default: 1
  end
end
