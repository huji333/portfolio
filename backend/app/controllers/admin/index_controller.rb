class Admin::IndexController < Admin::Base
  # ダッシュボードは作業ランチャー。残作業カウントのみ持つ（統計タイルは廃止）。
  # admin のみ・低トラフィックなので単純 count で十分（YAGNI）。
  def index
    @uncurated_count = Image.uncurated.count
    @uncurated_gear_count = Camera.uncurated.count + Lens.uncurated.count
  end
end
