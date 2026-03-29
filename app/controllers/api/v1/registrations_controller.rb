class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.new(registration_params)

    if user.save
      token = generate_jwt(user)
      render json: { token: "Bearer #{token}", user: user_json(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  def user_json(user)
    { id: user.id, name: user.name, email: user.email }
  end
end
