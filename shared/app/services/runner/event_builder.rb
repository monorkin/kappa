require_dependency 'runner'

class Runner
  ##
  # Infuses the request's data with the template's
  #
  class EventBuilder
    ##
    # Delegate method to the +call+ instance method.
    # This method builds a new object and calls +call+ on it.
    #
    # Please reference the +call+ and +initialize+ instance methods for
    # documentation.
    #
    def self.call(request, template)
      self.new(request, template).call
    end

    ##
    # Holds the request that triggered the Runner
    #
    attr_reader :request

    ##
    # Holds the template of the event for the Lambda
    #
    attr_reader :template

    ##
    # Memoizes the input data.
    #
    # @param [Request] request The Rails request object
    # @param [Template] template Tamplate objcet to build the Lambda event
    #
    def initialize(request, template)
      @request = request
      @template = template
    end

    ##
    # Interpolates the request's values with the Template's
    #
    # @return [Hash] The AWS Labda event hash
    #
    def call
      interpolate_body
      interpolate_headers
      interpolate_path
      interpolate_method
      interpolate_query
      template.data['json']
    end

    private

    ##
    # Sets the Template's value at the keys path.
    #
    # @param [Array] keys Path to the desired value
    # @param [Object] value The value to set at the path
    #
    def interpolate_value(keys, value)
      keys = keys.dup
      json = template.data['json']
      key = keys.pop
      return unless key

      keys.each do |key|
        json[key] ||= {}
        json = json[key]
      end

      json[key] = value
    end

    ##
    # Sets the request's body as the template's
    #
    def interpolate_body
      template.body_fields.each do |keys|
        interpolate_value(keys, request.body.read.force_encoding('utf-8'))
      end
    end

    ##
    # Sets the request's headers as the template's
    #
    def interpolate_headers
      template.headers_fields.each do |keys|
        interpolate_value(keys, http_headers)
      end
    end

    ##
    # Converts the request's raw Rack HTTP headers into a Hash of standard
    # HTTP headers.
    #
    # @return[Hash] Http headers
    #
    def http_headers
      headers_hash.each_with_object({}) do |(key, value), headers|
        name = key[5..-1].split('_').map(&:titleize).join('-')
        headers[name] = value
      end
    end

    ##
    # Raw request headers hash.
    #
    # @return [Hash] Raw Rack headers from the request
    #
    def headers_hash
      request.env.select do |key, _|
        key =~ /^HTTP_/
      end
    end

    ##
    # Interpolate the request's path in to the template's
    #
    def interpolate_path
      template.path_fields.each do |keys|
        interpolate_value(keys, request.path)
      end
    end

    ##
    # Interpolate the request's method in to the template's
    #
    def interpolate_method
      template.method_fields.each do |keys|
        interpolate_value(keys, request.method)
      end
    end

    ##
    # Interpolate the request's query in to the template's
    #
    def interpolate_query
      template.query_fields.each do |keys|
        interpolate_value(keys, request.params)
      end
    end
  end
end
