module Absurdity

  autoload :Metric, "absurdity/metric"
  autoload :Config, "absurdity/config"

  def self.redis
    Absurdity::Config.instance.redis
  end

  def self.redis=(redis)
    Absurdity::Config.instance.redis = redis
  end
end
