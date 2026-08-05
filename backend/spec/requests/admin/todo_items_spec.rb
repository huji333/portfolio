require 'rails_helper'
RSpec.describe 'Admin::TodoItems', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  describe 'GET /admin/todo_items' do
    it 'renders the sortable list with done checkboxes' do
      item = create(:todo_item, title: '富士山に登る', done: true)

      get admin_todo_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('富士山に登る')
      expect(response.body).to match(/data-sortable-id=['"]#{item.id}['"]/)
      expect(response.body).to include('todo_item[done]')
    end
  end

  describe 'POST /admin/todo_items' do
    it 'creates a todo item appended to the end' do
      create(:todo_item, position: 5)

      expect do
        post admin_todo_items_path, params: { todo_item: { title: '富士山に登る' } }
      end.to change(TodoItem, :count).by(1)

      expect(response).to redirect_to(admin_todo_items_path)
      expect(TodoItem.find_by(title: '富士山に登る').position).to eq(6)
    end

    it 'rejects a blank title' do
      post admin_todo_items_path, params: { todo_item: { title: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH /admin/todo_items/:id' do
    it 'toggles done (index の達成チェックボックス相当)' do
      item = create(:todo_item, done: false)

      patch admin_todo_item_path(item), params: { todo_item: { done: true } }

      expect(response).to redirect_to(admin_todo_items_path)
      expect(item.reload.done).to be(true)
    end
  end

  describe 'POST /admin/todo_items/:id/insert_at' do
    it 'moves the item to the given position and renumbers 0..N-1' do
      first = create(:todo_item, position: 0)
      second = create(:todo_item, position: 1)
      third = create(:todo_item, position: 2)

      post insert_at_admin_todo_item_path(third), params: { position: 0 }

      expect(response).to have_http_status(:ok)
      expect(TodoItem.ordered.pluck(:id)).to eq([third.id, first.id, second.id])
      expect(TodoItem.ordered.pluck(:position)).to eq([0, 1, 2])
    end

    it 'clamps an out-of-range position to the end' do
      first = create(:todo_item, position: 0)
      second = create(:todo_item, position: 1)

      post insert_at_admin_todo_item_path(first), params: { position: 99 }

      expect(response).to have_http_status(:ok)
      expect(TodoItem.ordered.pluck(:id)).to eq([second.id, first.id])
    end
  end
end
