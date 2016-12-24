ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'rails/commands/server'

module Rails
  # Override default development server port
  class Server
    def default_options
      super.merge(Host: '0.0.0.0', Port: 3000)
    end
  end
end