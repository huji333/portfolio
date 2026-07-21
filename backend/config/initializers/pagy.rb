require "pagy/extras/bootstrap"
require "pagy/extras/overflow"

# ページ数を超えた page param（一括操作でページ数が減った直後など）は最終ページに丸める
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT.freeze
