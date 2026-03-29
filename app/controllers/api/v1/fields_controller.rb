class Api::V1::FieldsController < ApplicationController
  FREE_PLAN_LIMIT = 10

  before_action :find_member_group!
  before_action :find_field!, only: [ :update, :destroy ]

  def index
    fields = @group.fields.includes(field_logs: :user).map do |field|
      latest = field.field_logs.order(created_at: :desc).first
      field_json(field, latest)
    end
    render json: { fields: fields }
  end

  def create
    if @group.fields.count >= FREE_PLAN_LIMIT
      return render json: { errors: [ "無料プランでは圃場を#{FREE_PLAN_LIMIT}件まで登録できます" ] },
                    status: :unprocessable_entity
    end

    field = @group.fields.build(field_params)
    if field.save
      render json: { field: field_json(field, nil) }, status: :created
    else
      render json: { errors: field.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @field.update(field_params)
      latest = @field.field_logs.order(created_at: :desc).first
      render json: { field: field_json(@field, latest) }
    else
      render json: { errors: @field.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @field.destroy
    head :no_content
  end

  private

  def find_field!
    @field = @group.fields.find_by(id: params[:id])
    render json: { errors: [ "圃場が見つかりません" ] }, status: :not_found unless @field
  end

  def field_params
    params.require(:field).permit(:name, :crop)
  end

  def field_json(field, latest_log)
    {
      id: field.id,
      name: field.name,
      crop: field.crop,
      latest_log: latest_log ? {
        status: latest_log.status,
        tags: latest_log.tags,
        memo: latest_log.memo,
        updated_at: latest_log.created_at,
        updated_by: latest_log.user.name
      } : nil
    }
  end
end
