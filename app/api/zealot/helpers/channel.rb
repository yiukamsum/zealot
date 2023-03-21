# frozen_string_literal: true

module Zealot::Helpers::Channel
  def determine_channel_params!
    return if (params.key?(:bundle_id) && params.key?(:git_commit)) ||
              (params.key?(:bundle_id) && params.key?(:release_version) &&
              params.key?(:build_version))

    raise ActionController::ParameterMissing, I18n.t('api.apps.version_exist.show.missing_params')
  end
end
