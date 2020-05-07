class Media

  def self.transfer_files(customer, variant)
    media_metafield = variant.metafields.select{|m| m.namespace == "witty" and m.key == "media"}.first
    customer_metafield = customer.metafields.select{|m| m.namespace == "witty" and m.key == "media_library"}.first
    product = ShopifyAPI::Product.find variant.product_id

    media_metafield_info = media_metafield.value + '}{' + product.handle

    if media_metafield
      if customer_metafield
        puts Colorize.magenta("metafield exists")
        customer_metafield.value = customer_metafield.value.add_tag media_metafield_info
        customer_metafield.save
      else
        puts Colorize.green("adding metafield")
        customer.add_metafield(ShopifyAPI::Metafield.new({
          namespace: "witty", 
          key: "media_library", 
          value: media_metafield_info, 
          value_type: "string"
        }))
      end
    else
      puts Colorize.cyan("nothing to transfer")
    end
  end

  def self.compare_order(order)
    customer = order.customer

    for item in order.line_items
      begin
        variant = ShopifyAPI::Variant.find item.variant_id
        transfer_files(customer, variant)
      rescue
        puts Colorize.red("variant not found")
      end
    end
  end

  def self.save_marketplace(customer, params)
    customer_metafield = customer.metafields.select{|m| m.namespace == "witty" and m.key == "media_library"}.first
    product = ShopifyAPI::Product.find params["product_id"]

    title = params["title"].gsub(/\(.*[a-zA-Z]{2}\)/, '').strip
    full_url = title + "||" + params["url"] + '}{' + product.handle

    if customer_metafield
      puts Colorize.cyan("metafield exists")

      if customer_metafield.value.match(/~\s*#{full_url}\|\|/)
        puts Colorize.cyan("already exists")
      else
        customer_metafield.value = customer_metafield.value.add_tag full_url
        if customer_metafield.save
          puts Colorize.green("Added to metafield") 
        end
      end
    else
      puts Colorize.green("adding metafield")
      customer.add_metafield(ShopifyAPI::Metafield.new({
        namespace: "witty", 
        key: "media_library", 
        value: full_url, 
        value_type: "string"
      }))
    end
    
  end

end