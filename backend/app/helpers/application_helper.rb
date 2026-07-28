module ApplicationHelper
  # pagy 43 は nav helper を Pagy インスタンスのメソッドとして提供するため
  # view helper の include は不要（Pagy::Frontend は廃止）。
end
