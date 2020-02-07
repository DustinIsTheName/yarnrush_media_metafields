class MediaController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:recieve_webhook, :save_marketplace]

  def recieve_webhook
    puts params

    order = ShopifyAPI::Order.find params["id"]
    Media.compare_order(order)

    head :ok
  end

  def save_marketplace
    headers['Access-Control-Allow-Origin'] = '*'
    puts params

    customer = ShopifyAPI::Customer.find params["customer"]
    Media.save_marketplace(customer, params)

    render json: params
  end

end