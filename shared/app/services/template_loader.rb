class TemplateLoader
  TEMPLATES_FOLDER = Rails.root.join('data/templates').freeze

  def self.call
    @templates ||= self.new.call
  end

  def call
    @templates ||= templates.sort_by(&:name)
  end

  private

  def templates
    template_data.map do |data|
      Template.new(data)
    end
  end

  def template_data
    template_files.map do |file|
      template = YAML.load(File.read(file))
      json = JSON.parse(File.read(TEMPLATES_FOLDER.join(template['json'])))
      template['json'] = json
      template
    end
  end

  def template_files
    Dir.entries(TEMPLATES_FOLDER)
      .map { |file| TEMPLATES_FOLDER.join(file) }
      .select do |file|
        File.file?(file) && File.extname(file) == '.yml'
      end
  end
end
