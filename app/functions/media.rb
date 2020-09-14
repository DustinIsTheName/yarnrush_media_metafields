class Media

  def self.transfer_files(customer, variant)
    media_title_metafields = variant.metafields.select{|m| m.namespace == "witty" and m.key == "media_title"}.first
    media_image_metafields = variant.metafields.select{|m| m.namespace == "witty" and m.key == "media_image"}.first
    media_metafields = variant.metafields.select{|m| m.namespace == "accentuate" and m.key == "media"}.first

    media_titles = JSON.parse media_title_metafields.value
    media_images = JSON.parse media_image_metafields.value
    medias = JSON.parse media_metafields.value

    for i in (0..medias.count-1)
      if media_images[i]&.first
        media_image = media_images[i]&.first["src"].split('?')&.first
      else
        media_image = nil
      end

      if medias[i]&.first
        media = medias[i]&.first["src"].split('?')&.first
      else
        media = nil
      end

      transfer_single_file(media_titles[i], media_image, media, customer, variant)
    end
  end

  def self.transfer_single_file(title, image, media, customer, variant)

    customer_metafield = customer.metafields.select{|m| m.namespace == "witty" and m.key == "media_library"}.first
    product = ShopifyAPI::Product.find variant.product_id

    if title.blank?
      title = product.title
    end

    if image.blank?
      image = product.images.select{|i| i.id == variant.image_id }.first

      unless image
        image = product.images.first.src
      end
    end

    if image
      media_metafield_info = media + '}{' + title + '==' + image
    else
      media_metafield_info = media + '}{' + title
    end

    if media
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

  def self.fulfill_order(order)

    no_shipping_line_items = []

    for item in order.line_items
      begin
        inventory_item_id = ShopifyAPI::Variant.find(item.variant_id).inventory_item_id
      rescue
        puts Colorize.red("couldn't find Variant")
      end

      if inventory_item_id
        inventory_item = ShopifyAPI::InventoryItem.find(inventory_item_id)
        inventory_level = ShopifyAPI::InventoryLevel.find(:all, params: {inventory_item_ids: inventory_item_id}).first

        unless inventory_item.requires_shipping
          no_shipping_line_items << item.id
        end
      end
    end

    unless no_shipping_line_items.count == 0
      f = ShopifyAPI::Fulfillment.new
      f.prefix_options[:order_id] = order.id
      f.notify_customer = true
      f.location_id = inventory_level.location_id  
      f.line_items = []

      for item_id in no_shipping_line_items
        f.line_items << {
          "id": item_id
        }
      end

      puts Colorize.yellow(inventory_level.location_id)
    end
  end

  def self.save_marketplace(customer, params)
    customer_metafield = customer.metafields.select{|m| m.namespace == "witty" and m.key == "media_library"}.first
    product = ShopifyAPI::Product.find params["product_id"]
    image = product.images.first

    title = params["title"].gsub(/\(.*[a-zA-Z]{2}\)/, '').strip
    if image
      full_url = title + "||" + params["url"] + '}{' + product.handle + '==' + image.src
    else
      full_url = title + "||" + params["url"] + '}{' + product.handle
    end
 
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