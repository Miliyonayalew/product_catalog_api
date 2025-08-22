# This routes file sets up the basic API endpoints.
Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Define API routes under a namespace for versioning
  namespace :api do
    namespace :v1 do
      resources :products do
        # Custom member route for featuring a product (for Task 3.2)
        # This route is correctly defined, but the controller action needs fixing.
        # Custom member routes for featuring/unfeaturing products (for Task 3.2)
        patch :feature, on: :member
        patch :unfeature, on: :member
      end
      resources :categories # Full CRUD for categories
    end
  end

  # Health check endpoint (example from provided `rails-frontend`)
  get "health" => "application#health"

  # Root URL (example from provided `rails-frontend`)
  root "application#index"
end
