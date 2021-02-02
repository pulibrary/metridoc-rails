# frozen_string_literal: true
class ActiveAdminAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    user.authorized?(action, subject)
  end
end
