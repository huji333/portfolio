class ApplicationController < ActionController::Base
  helper_method :failed_job_count

  private

  def file_dimensions(attachment)
    metadata = attachment.attached? ? attachment.metadata : {}
    [metadata['width']&.to_i, metadata['height']&.to_i]
  end

  # 管理画面ナビの「ジョブ」バッジ用件数。ログイン前ページ（layout 共有）でも
  # 呼ばれるため admin 判定込みで 0 を返す。集計失敗時も画面を落とさず 0 fallback
  # （fail-loud はジョブ本体側の責務なのでここでは rescue して log のみ）。
  def failed_job_count
    return 0 unless current_user&.role_admin?

    SolidQueue::FailedExecution.count
  rescue StandardError => e
    Rails.logger.error("failed_job_count: #{e.class} #{e.message}")
    0
  end
end
