##
# Handles all incoming requests
#
class ApplicationController < ActionController::Base
  ##
  # Single point of entry.
  # This function handles all incoming calls. It builds and executes a Runner
  # and returns the result.
  #
  def run
    type = Setting.type
    template = Setting.template
    result = Runner.call(request, type, template)
    set_headers(result[:headers])
    render **result
  end

  private

  ##
  # Sets the input Hash a the response's headers
  #
  def set_headers(headers_map)
    return unless headers_map
    headers_map.each do |key, value|
      response.set_header(key, value)
    end
  end
end
