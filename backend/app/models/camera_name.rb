class CameraName
  def self.resolve(make, model)
    return nil if make.blank? || model.blank?

    camera_names = load_camera_names
    make_key = make.upcase.strip
    model_key = model.upcase.strip

    # メーカー名で検索
    return camera_names[make_key][model_key] if camera_names[make_key]&.key?(model_key)

    # メーカー名が見つからない場合は、部分一致で検索
    camera_names.each do |manufacturer, models|
      next unless manufacturer.include?(make_key) || make_key.include?(manufacturer)
      return models[model_key] if models.key?(model_key)
    end

    # デフォルトは元のモデル名を返す
    model
  end

  def self.load_camera_names
    @load_camera_names ||= begin
      yaml_path = Rails.root.join("config/camera_names.yml")
      if File.exist?(yaml_path)
        YAML.load_file(yaml_path) || {}
      else
        {}
      end
    end
  end
end
