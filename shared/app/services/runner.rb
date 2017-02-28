##
# Runs Lambda containers of the given type with the given teplate.
#
class Runner
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
  # For avaialble types please reference ContainerBuilder::TYPE_LABEL_MAPPING
  #
  # @param [Request] request The Rails request object that triggered the Runner
  # @param [String] type Type of the container to run
  # @param [Template] template Tamplate objcet to build the Lambda event
  #
  def initialize(request, type, template)
    @request = request
    @type = type
    @template = template
  end

  ##
  # Builds a Rails type response Hash and loggs all errors from the container.
  #
  # @return [Hash] Rails type response hash that can be ffed to +render+
  #
  def call
    log_container_errors

    {
       response_type => result['body'],
       status: result['statusCode'],
       headers: result['headers']
    }
  end

  private

  ##
  # Log any +stderr+ output from the container to the standard error log
  #
  def log_container_errors
    return unless container_output[:stderr].present?
    Rails.logger.error(container_output[:stderr])
  end

  ##
  # Inferes and memoizes the response type from the request.
  # If no response type can be infered JSON is used as the default.
  #
  # @return [Symbol] The response type
  #
  def response_type
    @response_type ||= request.format.symbol || :json
  end

  ##
  # Builds and memoizes the Lambda's response as a Hash.
  #
  # @return [Hash] The Lambda's response
  #
  def result
    @result ||= JSON.parse(container_output[:stdout])
  end

  ##
  # Starts the container and returns it's +stdout+ and +stderr+ output as a
  # hash.
  #
  # @return [Hash] Mappings of +stdout+ and +stderr+
  #
  def container_output
    @container_output ||= begin
      container.start
      container.wait(4.minutes)

      {
        stdout: sanitize_container_output(container.logs(stdout: true)),
        stderr: sanitize_container_output(container.logs(stderr: true))
      }
    end
  ensure
    remove_residual_container
  end

  ##
  # Builds and memoizes a Cointener object with the given type and template.
  #
  # @return [Container] Container to run the Lambda
  #
  def container
    @container ||= ContainerBuilder.call(request, type, template)
  end

  ##
  # Sanitizes the container's +stdout+ and +stderr+ logs.
  #
  # Each line in Docker's logs starts with 8 bytes that indicate the start of
  # an entry, the type of output the line was written to, and so on...
  #
  # The first byte indicates if it was written to +stdout+ or +stderr+ while
  # the meaning of the last two bytes is unknown to me, but they can change.
  # All other bytes hav a value of 0.
  #
  # Also, lines can start and end with +\e+ followed by 4 byes.
  #
  # @param [String] output Unsanitized container log
  # @return [String] Sanitized container log
  #
  def sanitize_container_output(output)
    lines = output.split(/.\x00\x00\x00\x00\x00../im)

    sanitized_lines = lines.map do |line|
      line.gsub(/^\e..../, '').gsub(/\e.../m, '').presence
    end

    sanitized_lines.compact.join
  end


  ##
  # Remove residual containers
  #
  def remove_residual_container
    container.stop
    container.delete(force: true)
  rescue Docker::Error::NotFoundError
    nil
  end
end
