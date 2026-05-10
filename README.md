# Helios::Sitemap

Sitemap generation with S3 storage and IndexNow submission for Rails. Designed for ephemeral disk systems (Heroku, Docker) where you can't persist generated sitemaps to disk.

**Flow:** Generate sitemap -> Upload to S3 -> Serve from your app at `/sitemap.xml` -> Submit to IndexNow

## Installation

Add to your Gemfile:

```ruby
gem "helios-sitemap"
```

Then `bundle install`.

## Configuration

Create an initializer at `config/initializers/helios_sitemap.rb`:

```ruby
Helios::Sitemap.configure do |config|
  config.default_host = "https://example.com"

  # S3 storage (defaults to ENV vars if not set)
  config.aws_bucket     = ENV["AWS_SITEMAP_BUCKET"]
  config.aws_region     = ENV["AWS_REGION"]
  config.aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
  config.aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

  # IndexNow (defaults to ENV vars if not set)
  config.indexnow_domain  = ENV["INDEXNOW_DOMAIN"]
  config.indexnow_api_key = ENV["INDEXNOW_API_KEY"]

  # Define what goes in your sitemap
  config.sitemap_entries = ->(sitemap) {
    sitemap.add "/", changefreq: "weekly", priority: 1.0
    Post.published.find_each do |post|
      sitemap.add "/#{post.slug}", changefreq: "weekly", priority: 0.7
    end
  }

  # Define URLs to submit to IndexNow
  config.indexnow_urls = -> {
    urls = ["https://example.com/"]
    Post.published.find_each do |post|
      urls << "https://example.com/#{post.slug}"
    end
    urls
  }
end
```

## Routes

Mount the engine in your `config/routes.rb`:

```ruby
mount Helios::Sitemap::Engine, at: "/"
```

This provides:
- `GET /sitemap.xml` - Serves the sitemap XML from S3
- `GET /sitemap.xml.gz` - Serves the gzipped sitemap from S3

## Generating & Uploading

Trigger a sitemap refresh by running the job:

```ruby
Helios::Sitemap::RefreshJob.perform_later
```

You can schedule this however you prefer (cron, recurring job, after publishing content, etc.).

## Environment Variables

| Variable | Description |
|---|---|
| `AWS_SITEMAP_BUCKET` | S3 bucket name |
| `AWS_REGION` | AWS region |
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `INDEXNOW_DOMAIN` | Your domain for IndexNow |
| `INDEXNOW_API_KEY` | Your IndexNow API key |

## License

Proprietary. All rights reserved.
