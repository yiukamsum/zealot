# frozen_string_literal: true

class API::AppSerializer < ApplicationSerializer
  attributes :id, :name

  has_many :schemes
end
