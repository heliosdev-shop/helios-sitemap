require_relative "lib/helios/sitemap/version"

Gem::Specification.new do |spec|
  spec.name        = "helios-sitemap"
  spec.version     = Helios::Sitemap::VERSION
  spec.authors     = ["Jason Fleetwood-Boldt"]
  spec.email       = ["jason@heliosdev.shop"]
  spec.homepage    = "https://github.com/heliosdev/helios-sitemap"
  spec.summary     = "Sitemap generation with S3 storage and IndexNow submission for Rails"
  spec.description = "Generate sitemaps with sitemap_generator, upload to S3 for ephemeral disk systems, serve from your app at /sitemap.xml, and submit to IndexNow."
  spec.license     = "Nonstandard"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "sitemap_generator", "~> 6.3"
  spec.add_dependency "aws-sdk-s3", ">= 1.0"
end
