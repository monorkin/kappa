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
    render result
  end
end
