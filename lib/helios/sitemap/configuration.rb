module Helios
  module Sitemap
    class Configuration
      attr_accessor :default_host,
                    :aws_bucket,
                    :aws_region,
                    :aws_access_key_id,
                    :aws_secret_access_key,
                    :s3_object_key,
                    :indexnow_domain,
                    :indexnow_api_key,
                    :sitemap_entries,
                    :indexnow_urls

      def initialize
        @s3_object_key = "sitemaps/sitemap.xml.gz"
        @aws_region = ENV["AWS_REGION"]
        @aws_bucket = ENV["AWS_SITEMAP_BUCKET"]
        @aws_access_key_id = ENV["AWS_ACCESS_KEY_ID"]
        @aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
        @indexnow_domain = ENV["INDEXNOW_DOMAIN"]
        @indexnow_api_key = ENV["INDEXNOW_API_KEY"]
      end

      def s3_client
        Aws::S3::Client.new(
          region: aws_region,
          credentials: Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
        )
      end
    end
  end
end
