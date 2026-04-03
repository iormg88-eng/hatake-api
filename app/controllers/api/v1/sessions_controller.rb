class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    user = User.find_by(email: sign_in_params[:email])

    if user&.valid_password?(sign_in_params[:password])
      token = generate_jwt(user)
      render json: { token: "Bearer #{token}", user: user_json(user) }, status: :ok
    else
      render json: { errors: [ "メールアドレスまたはパスワードが正しくありません" ] },
             status: :unauthorized
    end
  end

  def destroy
    current_user&.update_column(:jti, SecureRandom.uuid)
    head :no_content
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  def user_json(user)
    group_id = user.group_members.first&.group_id
    { id: user.id, name: user.name, email: user.email, group_id: group_id }
  end
end
