class MediaController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:recieve_webhook, :save_marketplace]
  before_filter :cors_set_access_control_headers

  def recieve_webhook
    headers['Access-Control-Allow-Origin'] = '*'
    puts params

    order = ShopifyAPI::Order.find params["id"]
    Media.compare_order(order)
    Media.fulfill_order(order)

    head :ok
  end

  def save_marketplace
    headers['Access-Control-Allow-Origin'] = '*'
    puts params

    customer = ShopifyAPI::Customer.find params["customer"]
    Media.save_marketplace(customer, params)

    render json: params
  end

  private

    def set_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = '*'
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, PATCH, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end