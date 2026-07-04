class Admin::IndexController < Admin::Base
  # 統計はキャッシュしない。admin のみ・低トラフィックなので単純 count で十分（YAGNI）。
  def index
    @published_count = Image.published.count
    @draft_count     = Image.draft.count
    @uncurated_count = Image.uncurated.count
  end
end
