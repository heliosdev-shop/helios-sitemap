# frozen_string_literal: true

require "net/http"
require "json"

module Helios
  module Sitemap
    class IndexNowService
      ENDPOINT = "https://api.indexnow.org/IndexNow"

      class IndexNowError < StandardError; end

      class << self
        def submit_urls(urls)
          raise IndexNowError, "URLs array cannot be empty" if urls.blank?

          payload = build_payload(urls)
          make_request(payload)
        rescue IndexNowError
          raise
        rescue StandardError => e
          Rails.logger.error "IndexNow: Unexpected error - #{e.class}: #{e.message}"
          false
        end

        private

        def build_payload(urls)
          {
            host: domain,
            key: api_key,
            keyLocation: key_location_url,
            urlList: urls
          }
        end

        def make_request(payload)
          uri = URI(ENDPOINT)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.read_timeout = 10
          http.open_timeout = 10

          request = Net::HTTP::Post.new(uri.path)
          request["Content-Type"] = "application/json; charset=utf-8"
          request.body = payload.to_json

          response = http.request(request)
          handle_response(response)
        end

        def handle_response(response)
          case response.code.to_i
          when 200, 202
            Rails.logger.info "IndexNow: Successfully submitted URLs (#{response.code})"
            true
          when 400
            Rails.logger.error "IndexNow: Bad request (400) - #{response.body}"
            false
          when 403
            raise IndexNowError, "IndexNow: Forbidden (403) - Invalid or inaccessible API key. Verify key file at #{key_location_url}"
          when 422
            raise IndexNowError, "IndexNow: Unprocessable (422) - #{response.body}"
          when 429
            Rails.logger.warn "IndexNow: Rate limited (429)"
            false
          else
            Rails.logger.error "IndexNow: Unexpected response (#{response.code}) - #{response.body}"
            false
          end
        end

        def domain
          Helios::Sitemap.configuration.indexnow_domain || raise(IndexNowError, "indexnow_domain not configured")
        end

        def api_key
          Helios::Sitemap.configuration.indexnow_api_key || raise(IndexNowError, "indexnow_api_key not configured")
        end

        def key_location_url
          "https://#{domain}/#{api_key}.txt"
        end
      end
    end
  end
end
