# Helios::Sitemap

Sitemap generation with S3 storage and IndexNow submission for Rails. Designed for ephemeral disk systems (Heroku, Docker) where you can't persist generated sitemaps to disk.

**Flow:** Generate sitemap -> Upload to S3 -> Serve from your app at `/sitemap.xml` -> Submit to IndexNow

## Installation

Add to your Gemfile:

```ruby
gem "helios-sitemap"
```

Then:

```bash
bundle install
bin/rails generate helios:sitemap:install
```

The install generator creates three files in your app:

- `config/initializers/helios_sitemap.rb` — configuration (host, S3 settings, sitemap entries)
- `app/jobs/sitemap_refresh_job.rb` — background job that calls the refresh service
- `app/controllers/sitemap_controller.rb` — proxies the sitemap from S3
- Adds a `get "sitemap.xml"` route

## Configuration

Edit `config/initializers/helios_sitemap.rb`:

```ruby
Helios::Sitemap.configure do |config|
  config.default_host = "https://example.com"

  # S3 storage (defaults to ENV vars if not set)
  # config.aws_bucket     = ENV["AWS_SITEMAP_BUCKET"]
  # config.aws_region     = ENV["AWS_REGION"]
  # config.aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
  # config.aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
  # config.s3_object_key  = "sitemaps/sitemap.xml.gz"

  # Define what goes in your sitemap.
  # The block receives a SitemapGenerator::Sitemap instance.
  config.sitemap_entries = ->(sitemap) {
    sitemap.add "/", changefreq: "weekly", priority: 1.0

    # Dynamic entries from your database:
    # Post.published.find_each do |post|
    #   sitemap.add "/#{post.slug}", changefreq: "weekly", priority: 0.7
    # end
  }

  # IndexNow integration (optional)
  # config.indexnow_domain  = ENV["INDEXNOW_DOMAIN"]
  # config.indexnow_api_key = ENV["INDEXNOW_API_KEY"]
  # config.indexnow_urls = -> {
  #   Page.published.map { |p| "https://example.com/#{p.slug}" }
  # }
end
```

## Generating & Uploading

The installed `SitemapRefreshJob` calls `Helios::Sitemap::RefreshService.call`, which:

1. Generates `sitemap.xml.gz` using `sitemap_generator`
2. Uploads it to your configured S3 bucket
3. Submits URLs to IndexNow (if configured)

Schedule the job however your app handles recurring work:

```ruby
# Manual trigger
SitemapRefreshJob.perform_later

# With sidekiq-scheduler (config/sidekiq.yml):
# SitemapRefreshJob:
#   every: ['3d']
#   class: SitemapRefreshJob

# With any other job scheduler or cron
```

The job lives in your app so you can customize it — add error handling, logging, notifications, or call additional services after the sitemap refreshes.

## Serving the Sitemap

The installed `SitemapController` fetches the gzipped sitemap from S3 and serves it at `/sitemap.xml`. This works on ephemeral-disk platforms where the generated file wouldn't persist between deploys.

## Environment Variables

| Variable | Description |
|---|---|
| `AWS_SITEMAP_BUCKET` | S3 bucket name |
| `AWS_REGION` | AWS region |
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `INDEXNOW_DOMAIN` | Your domain for IndexNow (optional) |
| `INDEXNOW_API_KEY` | Your IndexNow API key (optional) |

## License

Proprietary. All rights reserved.
