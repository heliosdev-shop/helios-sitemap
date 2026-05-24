# frozen_string_literal: true

module Helios
  module Sitemap
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        desc "Installs Helios::Sitemap initializer, job, and controller into your app"

        def copy_initializer
          template "initializer.rb", "config/initializers/helios_sitemap.rb"
        end

        def copy_job
          template "sitemap_refresh_job.rb", "app/jobs/sitemap_refresh_job.rb"
        end

        def copy_controller
          template "sitemap_controller.rb", "app/controllers/sitemap_controller.rb"
        end

        def add_route
          route 'get "sitemap.xml", to: "sitemap#show"'
        end

        def print_next_steps
          say ""
          say "Helios::Sitemap installed!", :green
          say ""
          say "Next steps:"
          say "  1. Edit config/initializers/helios_sitemap.rb to configure your host and sitemap entries"
          say "  2. Set these ENV vars: AWS_REGION, AWS_SITEMAP_BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
          say "  3. Schedule SitemapRefreshJob in your job runner (e.g. sidekiq-scheduler)"
          say ""
        end
      end
    end
  end
end
