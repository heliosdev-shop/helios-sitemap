# frozen_string_literal: true

require "aws-sdk-s3"
require "zlib"

module Helios
  module Sitemap
    class SitemapController < ::ActionController::Base
      def show
        config = Helios::Sitemap.configuration

        gz_data = config.s3_client.get_object(
          bucket: config.aws_bucket,
          key: config.s3_object_key
        ).body.read

        if request.path.end_with?(".gz")
          render plain: gz_data,
                 content_type: "application/gzip",
                 content_disposition: 'attachment; filename="sitemap.xml.gz"'
        else
          xml_data = Zlib::GzipReader.new(StringIO.new(gz_data)).read
          render plain: xml_data, content_type: "application/xml"
        end
      rescue Aws::S3::Errors::NoSuchKey
        head :not_found
      end
    end
  end
end
