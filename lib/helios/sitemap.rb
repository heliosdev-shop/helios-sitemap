require "helios/sitemap/version"
require "helios/sitemap/engine"
require "helios/sitemap/configuration"
require "helios/sitemap/index_now_service"

module Helios
  module Sitemap
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end
  end
end
