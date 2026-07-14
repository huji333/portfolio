json.extract! image, :id, :title, :caption, :taken_at, :camera_id, :lens_id, :featured_rank, :is_published,
              :created_at, :updated_at
json.url image_url(image, format: :json)
