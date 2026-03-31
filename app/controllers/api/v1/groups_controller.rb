class Api::V1::GroupsController < ApplicationController
  before_action :find_member_group!, only: [ :show ]

  def create
    @group = Group.new(group_params)
    if @group.save
      @group.group_members.create!(user: current_user, role: "admin")
      render json: { group: group_base_json(@group) }, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    members = @group.group_members.includes(:user).map do |gm|
      { id: gm.user.id, name: gm.user.name, email: gm.user.email, role: gm.role }
    end

    fields = @group.fields.includes(field_logs: [:user, { photos_attachments: :blob }]).map do |field|
      latest = field.field_logs.order(created_at: :desc).first
      field_json(field, latest)
    end

    render json: {
      group: group_base_json(@group),
      members: members,
      fields: fields
    }
  end

  def join
    token = params[:invite_token].to_s.strip
    @group = Group.find_by(invite_token: token)
    return render json: { errors: [ "招待トークンが無効です" ] }, status: :not_found unless @group

    if @group.group_members.exists?(user: current_user)
      return render json: { errors: [ "すでにこのグループに参加しています" ] }, status: :conflict
    end

    @group.group_members.create!(user: current_user, role: "member")
    render json: { group: group_base_json(@group) }, status: :ok
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def group_base_json(group)
    { id: group.id, name: group.name, invite_token: group.invite_token }
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
        updated_by: latest_log.user.name,
        photo_urls: photo_urls_for(latest_log)
      } : nil
    }
  end
end
