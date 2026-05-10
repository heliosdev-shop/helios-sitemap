Helios::Sitemap::Engine.routes.draw do
  get "sitemap.xml",    to: "sitemap#show"
  get "sitemap.xml.gz", to: "sitemap#show"
end
