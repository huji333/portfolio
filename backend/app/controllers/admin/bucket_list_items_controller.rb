class Admin::BucketListItemsController < Admin::Base
  before_action :set_bucket_list_item, only: %i[edit update destroy insert_at]

  def index
    @bucket_list_items = BucketListItem.ordered
  end

  def new
    @bucket_list_item = BucketListItem.new
  end

  def edit; end

  def create
    @bucket_list_item = BucketListItem.new(bucket_list_item_params)
    @bucket_list_item.position = BucketListItem.next_position
    if @bucket_list_item.save
      redirect_to admin_bucket_list_items_path, notice: 'BucketListItem was successfully created.'
    else
      flash.now[:alert] = 'BucketListItem failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @bucket_list_item.update(bucket_list_item_params)
      redirect_to admin_bucket_list_items_path, notice: 'BucketListItem was successfully updated.'
    else
      flash.now[:alert] = 'BucketListItem failed to update.'
      render :edit, status: :unprocessable_content
    end
  end

  def insert_at
    ids = BucketListItem.ordered.where.not(id: @bucket_list_item.id).pluck(:id)
    ids.insert(insert_params.to_i.clamp(0, ids.size), @bucket_list_item.id)
    BucketListItem.reorder_positions!(ids)
    head :ok
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def destroy
    if @bucket_list_item.destroy
      redirect_to admin_bucket_list_items_path, notice: 'BucketListItem was successfully destroyed.'
    else
      redirect_to admin_bucket_list_items_path, alert: 'BucketListItem failed to destroy.'
    end
  end

  private

  def set_bucket_list_item
    @bucket_list_item = BucketListItem.find(params[:id])
  end

  def bucket_list_item_params
    params.expect(bucket_list_item: %i[title note done published])
  end

  def insert_params
    params.require(:position)
  end
end
