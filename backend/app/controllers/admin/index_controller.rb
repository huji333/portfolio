class Admin::IndexController < Admin::Base
  # ダッシュボードは作業ランチャー。残作業カウントのみ持つ（統計タイルは廃止）。
  # admin のみ・低トラフィックなので単純 count で十分（YAGNI）。
  def index
    @uncurated_count = Image.uncurated.count
    # 未整備機材数はモデル述語で判定するため Ruby 側で集計（admin のみ・低件数で YAGNI）
    @uncurated_gear_count = Camera.count(&:uncurated?) + Lens.count(&:uncurated?)
  end
end
