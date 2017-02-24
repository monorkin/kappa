##
# Data object that represents a Template
#
class Template
  ##
  # Memoizes the input data Hash
  #
  attr_accessor :data

  ##
  # Memoizes the input data Hash
  #
  # @param [Hash] data The template's data
  #
  def initialize(data)
    @data = data
  end

  ##
  # Returns the template's name
  #
  # @return [String] The template's name
  #
  def name
    data.dig('name')
  end

  ##
  # Returns and memoizes the template's body fields.
  #
  # @return [Array] Array of body fields
  #
  def body_fields
    @body_fields ||= arrayify(data.dig('fields', 'body')).compact
  end

  ##
  # Returns and memoizes the template's headers fields
  #
  # @return [Array] Array of headers fields
  #
  def headers_fields
    @headers ||= arrayify(data.dig('fields', 'headers')).compact
  end

  ##
  # Returns and memoizes the template's query fields
  #
  # @return [Array] Array of query fields
  #
  def query_fields
    @query_fields ||= arrayify(data.dig('fields', 'query')).compact
  end

  ##
  # Returns and memoizes the template's path fields
  #
  # @return [Array] Array of path fields
  #
  def path_fields
    @method_fields ||= arrayify(data.dig('fields', 'path')).compact
  end

  ##
  # Returns and memoizes the template's method fields
  #
  # @return [Array] Array of method fields
  #
  def method_fields
    @method_fields ||= arrayify(data.dig('fields', 'method')).compact
  end

  ##
  # Returns the template's body
  #
  def body
    data.json
  end

  private

  ##
  # Converts an input to an array of arrays
  #
  # @param [Object] fields Input fields that represent a path to a value
  # @return [Array] Array of arrays
  #
  def arrayify(fields)
    Array(fields).map do |sub_fields|
      Array(sub_fields)
    end
  end
end
