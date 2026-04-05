class Api::V1::GroupsController < ApplicationController
  before_action :find_member_group!, only: [ :show, :update, :leave ]

  def mine
    groups = current_user.groups.map do |g|
      {
        id: g.id,
        name: g.name,
        member_count: g.group_members.count,
        field_count: g.fields.count
      }
    end
    render json: { groups: groups }
  end

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

    fields = @group.fields.includes(field_logs: [ :user, { photos_attachments: :blob } ]).map do |field|
      latest = field.field_logs.order(created_at: :desc).first
      field_json(field, latest)
    end

    render json: {
      group: group_base_json(@group),
      members: members,
      fields: fields
    }
  end

  def update
    unless @membership.role == "admin"
      return render json: { errors: [ "管理者のみグループ名を編集できます" ] }, status: :forbidden
    end

    if @group.update(group_params)
      render json: { group: group_base_json(@group) }
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def join
    token = params[:invite_token].to_s.strip
    @group = Group.find_by(invite_token: token)
    return render json: { errors: [ "招待トークンが無効です" ] }, status: :not_found unless @group

    if @group.group_members.exists?(user: current_user)
      return render json: { errors: [ "すでにこのグループに参加しています" ] }, status: :conflict
    end

    if current_user.plan == "free" && current_user.group_members.count >= 1
      return render json: { errors: [ "無料プランでは複数のグループに参加できません" ] }, status: :forbidden
    end

    @group.group_members.create!(user: current_user, role: "member")
    render json: { group: group_base_json(@group) }, status: :ok
  end

  def leave
    ActiveRecord::Base.transaction do
      members = @group.group_members.order(:created_at)

      if members.count == 1
        # 最後の1人ならグループごと削除
        @group.destroy
      elsif @membership.role == "admin"
        # adminが抜ける場合は次のメンバーをadminに昇格
        next_member = members.where.not(id: @membership.id).first
        next_member.update!(role: "admin")
        @membership.destroy
      else
        @membership.destroy
      end
    end

    head :no_content
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
