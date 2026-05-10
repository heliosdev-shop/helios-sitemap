module Helios
  module Sitemap
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
