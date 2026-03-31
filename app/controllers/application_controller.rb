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

  def photo_urls_for(log)
    return [] unless log.photos.attached?
    log.photos.filter_map do |p|
      blob = p.blob
      next nil unless blob.service_name == "amazon"
      begin
        service = blob.service
        Rails.logger.info "[photo_urls_for] service=#{service.class}"
        Rails.logger.info "[photo_urls_for] AWS_KEY present=#{ENV['AWS_ACCESS_KEY_ID'].present?} length=#{ENV['AWS_ACCESS_KEY_ID']&.length}"
        bucket = service.respond_to?(:bucket) ? service.bucket : service.instance_variable_get(:@bucket)
        Rails.logger.info "[photo_urls_for] bucket=#{bucket.class} nil=#{bucket.nil?}"
        client = bucket.client
        Rails.logger.info "[photo_urls_for] client credentials class=#{client.config.credentials.class}"
        presigner = Aws::S3::Presigner.new(client: client)
        presigner.presigned_url(:get_object, bucket: "hatake-field-photos", key: blob.key, expires_in: 3600)
      rescue => e
        Rails.logger.error "[photo_urls_for] #{e.class}: #{e.message}"
        Rails.logger.error "[photo_urls_for] backtrace: #{e.backtrace.first(3).join(' | ')}"
        nil
      end
    end
  end

  def find_member_group!
    @group = Group.find(params[:group_id] || params[:id])
    @membership = @group.group_members.find_by(user: current_user)
    render_forbidden unless @membership
  end
end
