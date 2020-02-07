Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/transfer-media' => 'media#recieve_webhook'
  post '/save-marketplace-media' => 'media#save_marketplace'

end
