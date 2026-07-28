require "pagy"

# pagy 43 では helper が Pagy インスタンスのメソッドになったため extras の require は不要。
# また :overflow オプションは廃止され、範囲外ページは「空ページ」を返すようになった。
# 最終ページへの丸め込み（一括操作でページ数が減った直後など）は
# Admin::ImagesController が :raise_range_error + rescue で行う。
Pagy::OPTIONS.freeze
