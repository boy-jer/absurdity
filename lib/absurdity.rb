module Absurdity

  autoload :Metric, "absurdity/metric"

  def self.redis
    @@redis ||= Redis.new
  end

  def self.redis=(redis)
    @@redis = redis
  end
end
