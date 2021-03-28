# frozen_string_literal: true

require_relative 'book'
require_relative 'stationery'

# The class that contains all our products
class ShopList
  def initialize(id1, name, products = [])
    @id = id1
    @name = name
    @products = if products.nil?
                  []
                else
                  products.map do |product|
                    [product.id, product]
                  end.to_h
                end
  end

  attr_reader :name
  attr_reader :id

  def all_products
    @products.values
  end

  def all_stationerys
    stationerys = []
    @products.select do |_id, product|
      stationery.append(product) if product.class == stationery
    end
    stationerys
  end

  def size
    @products.keys.max
  end

  def names
    names = []
    @products.select do |_id, product|
      names.append(product.title) if !names.include?(product.title)
    end
    names
  end

  def number_by_name(name)
    number = 0
    @products.select do |_id, product|
      number += 1 if name == product.title
    end
    number
  end

  def price
    price = 0
    (0..@products.keys.max).each do |_id|
      price += @products[product_id].price
    end
    price
  end

  def product_by_id(id)
    @products[id]
  end

  def add_products(product)
    product_id =if @products.empty?
                  1
                else
                  @products.keys.max + 1
                end
    @products[product_id] = product
    # @products[product_id]
    @products.values
  end

  def add_real_product(product)
    @products[product.id] = product
  end

  def update_book(id, parameters)
    product = @products[id]
    parameters.to_h.each do |key, value|
      product[key] = value
    end
  end

  def delete_product(id)
    @products.delete(id)
  end

  def delete_product_by_name(name, num)
    k = 0
    @products.select do |id, product|
       if k == num
        break
      elsif (name == product.title) && (k < num)
          @products.delete(id)
          k += 1        
      end 
    end
  end
end
