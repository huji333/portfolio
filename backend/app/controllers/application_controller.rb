class ApplicationController < ActionController::Base
  private

  def file_dimensions(attachment)
    metadata = attachment.attached? ? attachment.metadata : {}
    [metadata['width']&.to_i, metadata['height']&.to_i]
  end
end
