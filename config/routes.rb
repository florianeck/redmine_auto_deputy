RedmineApp::Application.routes.draw do
  resources :user_deputies, only: [:index, :create] do

    member do
      get :move_up
      get :move_down
      get :delete
    end

    collection do
      post :set_availabilities
      post :set_permissions
      get  :projects_for_user
      post :toggle_watch_issues
    end
  end
end