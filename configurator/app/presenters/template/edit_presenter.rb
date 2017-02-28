class Template
  class EditPresenter
    def record
      @record ||= Setting.find_by!(key: 'template')
    end

    def template
      @template ||= begin
        template_data = begin
          JSON.parse(record.value)
        rescue
          {}
        end

        Template.new(template_data)
      end
    end

    def templates
      @templates ||= TemplateLoader.call
    end

    def available_templates
      @available_templates ||=
        templates.each_with_object({}) do |template, hash|
          hash[template.name] = template.name
        end
    end
  end
end
