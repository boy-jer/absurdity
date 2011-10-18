module Absurdity
  class Engine < Rails::Engine

    initializer "static assets" do |app|
      app.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
