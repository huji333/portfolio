class Api::TodoItemsController < ApplicationController
  def index
    items = TodoItem.published.ordered
    liked_ids = liked_item_ids(items)
    render json: items.map { |item| item.api_json(liked: liked_ids.include?(item.id)) }
  end

  private

  def liked_item_ids(items)
    return Set.new if params[:device_uuid].blank?

    TodoLike.where(todo_item: items, device_uuid: params[:device_uuid]).pluck(:todo_item_id).to_set
  end
end
