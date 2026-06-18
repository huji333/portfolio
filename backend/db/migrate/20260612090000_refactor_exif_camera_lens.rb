class RefactorExifCameraLens < ActiveRecord::Migration[8.1]
  def change
    # Camera: store raw EXIF Make/Model as the natural key. Existing name/manufacturer
    # become editable display values.
    add_column :cameras, :make, :string
    add_column :cameras, :model, :string
    add_index :cameras, %i[make model], unique: true

    # Lens: store raw EXIF LensModel as the natural key (nullable so the manually
    # curated 'Built-in lens', which has no EXIF name, can coexist).
    add_column :lenses, :exif_name, :string
    add_index :lenses, :exif_name, unique: true

    # fail-open: a photo without resolvable camera/lens EXIF must not block upload.
    change_column_null :images, :camera_id, true
    change_column_null :images, :lens_id, true
  end
end
