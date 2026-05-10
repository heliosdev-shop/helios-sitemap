# frozen_string_literal: true

require "sitemap_generator"
require "aws-sdk-s3"

module Helios
  module Sitemap
    class RefreshJob < ApplicationJob
      queue_as :default

      def perform
        config = Helios::Sitemap.configuration

        urls = collect_urls(config)

        generate_sitemap(config)
        upload_to_s3(config) unless Rails.env.development?
        submit_to_indexnow(urls)
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

        transfer_manager = Aws::S3::TransferManager.new(client: config.s3_client)

        transfer_manager.upload_file(
          file_path,
          bucket: config.aws_bucket,
          key: config.s3_object_key,
          content_type: "application/gzip"
        )

        Rails.logger.info("[helios-sitemap] Uploaded sitemap to s3://#{config.aws_bucket}/#{config.s3_object_key}")
      end

      def collect_urls(config)
        return [] unless config.indexnow_urls

        config.indexnow_urls.call
      end

      def submit_to_indexnow(urls)
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
