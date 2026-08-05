class Api::TodoLikesController < ApplicationController
  # cross-origin SPA からの呼び出しで session cookie を使わないため CSRF 対象外
  skip_forgery_protection

  before_action :set_todo_item

  def create
    like = @todo_item.todo_likes.create_or_find_by!(device_uuid: params[:device_uuid])
    # 既にいいね済みなら counter は動いていないので再取得しない
    @todo_item.reload if like.previously_new_record?
    render json: @todo_item.api_json(liked: true)
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def destroy
    removed = @todo_item.todo_likes.find_by(device_uuid: params[:device_uuid])&.destroy!
    @todo_item.reload if removed
    render json: @todo_item.api_json(liked: false)
  end

  private

  def set_todo_item
    @todo_item = TodoItem.published.find(params[:todo_item_id])
  end
end
