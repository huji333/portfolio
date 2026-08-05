class Admin::TodoItemsController < Admin::Base
  before_action :set_todo_item, only: %i[edit update destroy insert_at]

  def index
    @todo_items = TodoItem.ordered
  end

  def new
    @todo_item = TodoItem.new
  end

  def edit; end

  def create
    @todo_item = TodoItem.new(todo_item_params)
    @todo_item.position = TodoItem.next_position
    if @todo_item.save
      redirect_to admin_todo_items_path, notice: 'TodoItem was successfully created.'
    else
      flash.now[:alert] = 'TodoItem failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @todo_item.update(todo_item_params)
      redirect_to admin_todo_items_path, notice: 'TodoItem was successfully updated.'
    else
      flash.now[:alert] = 'TodoItem failed to update.'
      render :edit, status: :unprocessable_content
    end
  end

  def insert_at
    ids = TodoItem.ordered.where.not(id: @todo_item.id).pluck(:id)
    ids.insert(insert_params.to_i.clamp(0, ids.size), @todo_item.id)
    TodoItem.reorder_positions!(ids)
    head :ok
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def destroy
    if @todo_item.destroy
      redirect_to admin_todo_items_path, notice: 'TodoItem was successfully destroyed.'
    else
      redirect_to admin_todo_items_path, alert: 'TodoItem failed to destroy.'
    end
  end

  private

  def set_todo_item
    @todo_item = TodoItem.find(params[:id])
  end

  def todo_item_params
    params.expect(todo_item: %i[title note done published])
  end

  def insert_params
    params.require(:position)
  end
end
