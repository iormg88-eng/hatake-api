class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = extract_token
    return render_unauthorized unless token

    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    @current_user = User.find_by(id: payload["sub"])
    return render_unauthorized unless @current_user

    # JTI check: ensure the token hasn't been revoked
    render_unauthorized if User.jwt_revoked?(payload, @current_user)
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    render_unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token
    request.headers["Authorization"]&.gsub(/\ABearer /, "")
  end

  def render_unauthorized
    render json: { errors: [ "認証が必要です" ] }, status: :unauthorized
  end

  def render_forbidden
    render json: { errors: [ "このグループへのアクセス権がありません" ] }, status: :forbidden
  end

  def find_member_group!
    @group = Group.find(params[:group_id] || params[:id])
    @membership = @group.group_members.find_by(user: current_user)
    render_forbidden unless @membership
  end
end
