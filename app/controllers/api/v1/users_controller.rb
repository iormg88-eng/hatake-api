class Api::V1::UsersController < ApplicationController
  def me
    group_id = current_user.group_members.first&.group_id
    render json: { user: { id: current_user.id, name: current_user.name, email: current_user.email, group_id: group_id, plan: current_user.plan } }
  end
end
