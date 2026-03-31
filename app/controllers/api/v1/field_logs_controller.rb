class Api::V1::FieldLogsController < ApplicationController
  before_action :find_field!

  def index
    logs = @field.field_logs
                 .includes(:user)
                 .order(created_at: :desc)
                 .limit(20)

    render json: { field_logs: logs.map { |log| log_json(log, include_photos: true) } }
  end

  def create
    log = @field.field_logs.build(log_params.merge(user: current_user))

    if log.save
      render json: { field_log: log_json(log, include_photos: false) }, status: :created
    else
      render json: { errors: log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_field!
    field_id = params[:field_id] || params.dig(:field_log, :field_id)
    @field = Field.find_by(id: field_id)
    return render json: { errors: [ "圃場が見つかりません" ] }, status: :not_found unless @field

    group = @field.group
    unless group.group_members.exists?(user: current_user)
      render_forbidden
    end
  end

  def log_params
    params.require(:field_log).permit(:status, :memo, :field_id, tags: [], photos: [])
  end

  def log_json(log, include_photos: true)
    {
      id: log.id,
      status: log.status,
      tags: log.tags,
      memo: log.memo,
      created_at: log.created_at,
      user: { id: log.user.id, name: log.user.name },
      photo_urls: include_photos ? photo_urls_for(log) : []
    }
  end

end
