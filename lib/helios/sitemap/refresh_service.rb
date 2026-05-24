# frozen_string_literal: true

require "sitemap_generator"
require "aws-sdk-s3"

module Helios
  module Sitemap
    class RefreshService
      def self.call
        new.call
      end

      def call
        config = Helios::Sitemap.configuration

        generate_sitemap(config)
        upload_to_s3(config) unless Rails.env.development?
        submit_to_indexnow(config)
      end

      private

      def generate_sitemap(config)
        Rails.logger.info("[helios-sitemap] Generating sitemap...")

        SitemapGenerator::Sitemap.default_host = config.default_host

        entries_proc = config.sitemap_entries
        SitemapGenerator::Sitemap.create do
          entries_proc&.call(self)
        end
      end

      def upload_to_s3(config)
        file_path = Rails.root.join("public", "sitemap.xml.gz")

        s3 = Aws::S3::Resource.new(
          region: config.aws_region,
          credentials: Aws::Credentials.new(config.aws_access_key_id, config.aws_secret_access_key)
        )

        obj = s3.bucket(config.aws_bucket).object(config.s3_object_key)
        obj.upload_file(file_path.to_s, content_type: "application/gzip")

        Rails.logger.info("[helios-sitemap] Uploaded sitemap to s3://#{config.aws_bucket}/#{config.s3_object_key}")
      end

      def submit_to_indexnow(config)
        return unless config.indexnow_urls

        urls = config.indexnow_urls.call
        return unless urls.any?

        Rails.logger.info("[helios-sitemap] Submitting #{urls.count} URLs to IndexNow")
        IndexNowService.submit_urls(urls)
      rescue IndexNowService::IndexNowError => e
        Rails.logger.error("[helios-sitemap] IndexNow configuration error: #{e.message}")
      rescue StandardError => e
        Rails.logger.error("[helios-sitemap] Unexpected error submitting to IndexNow: #{e.class} - #{e.message}")
      end
    end
  end
end
