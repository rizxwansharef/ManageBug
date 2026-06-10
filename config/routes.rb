Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }, path: "", path_names: { sign_in: "/login", sign_out: "/logout", registration: "/signup" }

  devise_scope :user do
    get "/role", to: "registrations#role", as: :select_role
  end
  get "home", to: "pages#home"
  root "pages#home"
  resources :projects do
    member do
      get :available_users
    end
  end
  resources :bugs do
    member do
      patch "change_status"
    end
  end
  get "notifications", to: "notifications#index", as: "notifications"
  patch "notifications/mark_all_as_read", to: "notifications#mark_all_as_read", as: "mark_all_as_read_notifications"
end
