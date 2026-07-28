# ページ数を超えた page param（一括操作でページ数が減った直後など）を最終ページに丸める。
# pagy 43 で :overflow オプションが廃止され、範囲外ページは既定で空ページを返すように
# なったため、:raise_range_error で検出して最終ページを引き直す。
module Admin::ClampedPagination
  extend ActiveSupport::Concern

  included do
    include Pagy::Method
  end

  private

  def pagy_clamped(scope, **)
    pagy(scope, raise_range_error: true, **)
  rescue Pagy::RangeError => e
    pagy(scope, page: e.pagy.last, **)
  end
end
