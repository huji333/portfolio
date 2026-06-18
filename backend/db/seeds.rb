# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Built-in lens for fixed-lens cameras (compact / X half etc.). Assigned manually
# from the admin form when a photo has no LensModel EXIF.
Lens.find_or_create_by!(name: 'Built-in lens')

# Seed display names for known cameras (migrated from the former config/camera_names.yml).
# New cameras are auto-created from EXIF with raw make/model; these just give nicer labels.
[
  { make: 'SONY', model: 'ILCE-7CM2', manufacturer: 'SONY', name: 'a7C II' },
  { make: 'FUJIFILM', model: 'X-HF1', manufacturer: 'FUJIFILM', name: 'X half' }
].each do |attrs|
  camera = Camera.find_or_initialize_by(make: attrs[:make], model: attrs[:model])
  camera.update!(manufacturer: attrs[:manufacturer], name: attrs[:name])
end
