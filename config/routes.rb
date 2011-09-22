Rails.application.routes.draw do

  resources :absurdities,
            :format => :html,
            :only   => [:index, :show, :create]

end