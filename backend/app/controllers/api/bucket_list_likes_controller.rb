class Api::BucketListLikesController < ApplicationController
  # cross-origin SPA からの呼び出しで session cookie を使わないため CSRF 対象外
  skip_forgery_protection

  before_action :set_bucket_list_item

  def create
    like = @bucket_list_item.bucket_list_likes.create_or_find_by!(device_uuid: params[:device_uuid])
    # 既にいいね済みなら counter は動いていないので再取得しない
    @bucket_list_item.reload if like.previously_new_record?
    render json: @bucket_list_item.api_json(liked: true)
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def destroy
    removed = @bucket_list_item.bucket_list_likes.find_by(device_uuid: params[:device_uuid])&.destroy!
    @bucket_list_item.reload if removed
    render json: @bucket_list_item.api_json(liked: false)
  end

  private

  def set_bucket_list_item
    @bucket_list_item = BucketListItem.published.find(params[:bucket_list_item_id])
  end
end
