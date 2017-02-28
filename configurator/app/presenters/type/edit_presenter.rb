module Type
  class EditPresenter
    def record
      @record ||= Setting.find_by!(key: 'type')
    end

    def available_types
      ::Runner::ContainerBuilder::TYPE_LABEL_MAPPING
    end
  end
end
