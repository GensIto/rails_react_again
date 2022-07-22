Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "tasks" => "tasks#index"
  post "tasks" => "tasks#create"
  delete "tasks/:id" => "tasks#destroy"
  put "tasks/:id" => "tasks#update"
end
