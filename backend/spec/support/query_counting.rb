# 特定テーブルへの SQL 発行を回帰テストで固定するためのヘルパー（N+1 の再発防止用）。
module QueryCounting
  def sql_queries_matching(pattern, &)
    queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] if payload[:sql].match?(pattern)
    end
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &)
    queries
  end
end

RSpec.configure { |config| config.include QueryCounting }
