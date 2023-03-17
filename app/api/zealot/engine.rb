module Zealot
  class Engine < Grape::API
    prefix 'beta'
    format :json
    mount Zealot::App

    add_swagger_documentation
  end
end
