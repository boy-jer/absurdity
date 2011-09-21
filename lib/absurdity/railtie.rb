module Absurdity
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      load ::Rails.root.join("absurdity/experiments.rb")
      Absurdity::Config.instance.logger = ::Rails.logger
    end
  end
end