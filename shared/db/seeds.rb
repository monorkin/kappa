# Set default type
type = Setting.find_by(key: 'type')
if !type
  Setting.create(key: 'type', value: 'Vanilla')
end

# Set default template
template = Setting.find_by(key: 'template')
if !template
  name = 'API Gateway AWS Proxy'
  template = TemplateLoader.call.select do |template|
    template.name == name
  end.first

  Setting.create(key: 'template', value: template.data.to_json)
end

