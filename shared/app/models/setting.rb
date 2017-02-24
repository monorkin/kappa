##
# Represents a setting
#
class Setting < ApplicationRecord
  ##
  # Returns the type of the container to use
  #
  def self.type
    self.find_by!(key: 'type').value
  end

  ##
  # Returns the Template object ot use
  #
  def self.template
    json = JSON.parse(self.find_by!(key: 'template').value)
    Template.new(json)
  rescue
    Rails.logger.error('Invalid template format')
    Template.new({})
  end
end
