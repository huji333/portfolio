class Api::BucketListItemsController < ApplicationController
  def index
    items = BucketListItem.published.ordered
    liked_ids = liked_item_ids(items)
    render json: items.map { |item| item.api_json(liked: liked_ids.include?(item.id)) }
  end

  private

  def liked_item_ids(items)
    return Set.new if params[:device_uuid].blank?

    BucketListLike.where(bucket_list_item: items, device_uuid: params[:device_uuid]).pluck(:bucket_list_item_id).to_set
  end
end
