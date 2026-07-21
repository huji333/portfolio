require 'rails_helper'

RSpec.describe 'Admin nav job badge', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  def create_failed_execution
    job = SolidQueue::Job.create!(
      queue_name: 'default', class_name: 'ProcessAttachedFileJob', arguments: '[]'
    )
    SolidQueue::FailedExecution.create!(
      job: job, error: { exception_class: 'StandardError', message: 'boom', backtrace: [] }
    )
  end

  describe 'GET /admin' do
    it 'does not show the ジョブ badge when there are no failed executions' do
      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('admin-job-badge')
    end

    it 'shows the ジョブ badge with the failed execution count and links to /admin/jobs' do
      create_failed_execution
      create_failed_execution

      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('/admin/jobs')
      expect(response.body).to include('admin-job-badge')
      expect(response.body).to include('>2<')
    end

    it 'falls back to hiding the badge and logs instead of raising a 500 when the count query fails' do
      allow(SolidQueue::FailedExecution).to receive(:count).and_raise(ActiveRecord::StatementInvalid, 'boom')
      allow(Rails.logger).to receive(:error)

      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('admin-job-badge')
      expect(Rails.logger).to have_received(:error).with(/failed_job_count/)
    end
  end
end
