class Api::V1::UsersController < ApplicationController
  def me
    render json: { user: { id: current_user.id, name: current_user.name, email: current_user.email } }
  end
end
