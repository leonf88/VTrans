VTrans::Application.routes.draw do
  delete "users" => 'transcode#index'
  devise_for :users
  root :to => 'transcode#index'
  resources :upload do
    collection do
      get 'list'
      post 'delete'
      post 'check'
      post 'create' => 'upload#create'
      get 'index'
      get 'video_info'
    end
  end

  resources :transcode do
    collection do
      get 'list'
      post 'status'
      post 'check'
      post 'submit'
      post 'delete'
      get 'file_list'
      get 'video_info'
      get 'download/:id' => 'transcode#download'
    end
  end
end
