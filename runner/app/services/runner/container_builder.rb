require_dependency 'runner'

class Runner
  ##
  # Builds a Docker Container base on the input params
  #
  class ContainerBuilder
    ##
    # Mappings of human understandable strings to container labels aka. types.
    #
    TYPE_LABEL_MAPPING = {
      'vanilla' => nil,
      'nodejs4.3' => 'nodejs',
      'python2.7' => 'python2.7'
    }.freeze

    ##
    # Delegate method to the +call+ instance method.
    # This method builds a new object and calls +call+ on it.
    #
    # Please reference the +call+ and +initialize+ instance methods for
    # documentation.
    #
    def self.call(request, type, template)
      self.new(request, type, template).call
    end

    ##
    # Holds the request that triggered the Runner
    #
    attr_reader :request

    ##
    # Holds the type of container to build
    #
    attr_reader :type

    ##
    # Holds the template of the event for the Lambda
    #
    attr_reader :template

    ##
    # Memoizes the input data.
    #
    # For avaialble types please reference TYPE_LABEL_MAPPING
    #
    # @param [Request] request The Rails request object
    # @param [String] type Type of the container to run
    # @param [Template] template Tamplate objcet to build the Lambda event
    #
    def initialize(request, type, template)
      @request = request
      @type = type
      @template = template
    end

    ##
    # Builds a docker container with the given image, command, enviroment
    # variables and volume bindings.
    #
    # @return [Container] Lambda Docker container
    #
    def call
      Docker::Container.create(
        'Image' => image,
        'Cmd' => command,
        'Env' => environment,
        'Binds' => binds
      )
    end

    private

    ##
    # Builds and memoizes the full Docker image name used to build the container
    #
    # @return [String] Docker image name for container
    #
    def image
      @image ||= ['lambci/lambda', label].compact.join(':')
    end

    ##
    # Builds and memoizes the container's image label
    #
    # @return [String] The Docker image's label
    #
    def label
      @label ||= TYPE_LABEL_MAPPING[type.to_s.downcase]
    end

    ##
    # Builds and memoizes the command for the container to run. It consists of
    # the handler and the event.
    #
    # @return [String] The command to run in the Lambda container
    #
    def command
      @command ||= [handler.presence, event.presence].compact
    end

    ##
    # Builds and memoizes a map of environemnt variables to pass to the
    # Docker container.
    #
    # @return [Array] The current environmetn varialbles as an Array
    #
    def environment
      @environment ||= ENV.map do |key, value|
        "#{key}=#{value}"
      end
    end

    ##
    # Builds and memoizes volume bindings.
    #
    # @return [Array] Array of local to container volume bindings
    #
    def binds
      @binds ||= ["#{ENV['PROJECT_ROOT']}:/var/task"]
    end

    ##
    # Determines and memoizes the handler function.
    #
    # @return [String] Name of the handler function
    #
    def handler
      @handler ||= ENV['HANDLER'] || 'index.handler'
    end

    ##
    # Generates and memoizes an AWS Lambda event JSON
    #
    # @return [String] AWS Lambda event
    #
    def event
      @event ||= ::Runner::EventBuilder.call(request, template).to_json
    end
  end
end
