module Absurdity
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      load ::Rails.root.join("absurdity/experiments.rb")
    end
  end
end