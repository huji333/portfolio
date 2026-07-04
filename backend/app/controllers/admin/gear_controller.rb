class Admin::GearController < Admin::Base
  # カメラ・レンズを1画面に統合表示する。使用枚数はグループクエリで取得して N+1 を避ける。
  # 未整備（EXIF 自動生成のまま表示名を整えていない）を先頭に、以下使用枚数の降順で並べる。
  def index
    @camera_usage = Image.where.not(camera_id: nil).group(:camera_id).count
    @lens_usage   = Image.where.not(lens_id: nil).group(:lens_id).count

    @cameras = Camera.all.sort_by { |c| [c.uncurated? ? 0 : 1, -(@camera_usage[c.id] || 0), c.display_label] }
    @lenses  = Lens.all.sort_by { |l| [l.uncurated? ? 0 : 1, -(@lens_usage[l.id] || 0), l.name] }
  end
end
