# frozen_string_literal: true

require 'psych'
require_relative 'book_list'
require_relative 'book'
require_relative 'stationery_list'
require_relative 'stationery'
require_relative 'shop_list'
require_relative 'shop_lists'

# Storage for all of our data
class Store
  attr_reader :book_list
  attr_reader :stationery_list
  attr_reader :shopping_lists
  attr_reader :shop_list

  # attr_reader :lists
  DATA_STORE = File.expand_path('../db/data.yaml', __dir__)
  DATA_STORE1 = File.expand_path('../db/data1.yaml', __dir__)
  DATA_STORE2 = File.expand_path('../db/data2.yaml', __dir__)

  def initialize
    @book_list = BookList.new
    @stationery_list = StationeryList.new
    read_data
    read_data1
    @shopping_lists = ShopLists.new
    @shopping_lists = ShopLists.new([ShopList.new(1, 'book', @book_list.all_books), ShopList.new(2, 'MyFirstList')])
    #  read_data2
    #  @list = ShoppingList.new('MyFirstList',nil)
    #  @shopping_lists = Lists.new(ShopList.new('MyFirstList'))
    at_exit { write_data }
    at_exit { write_data1 }
    at_exit { write_data2 }
  end

  def read_data
    return unless File.exist?(DATA_STORE)

    yaml_data = File.read(DATA_STORE)
    raw_data = Psych.load(yaml_data, symbolize_names: true)
    raw_data[:book_list].each do |raw_book|
      @book_list.add_real_book(Book.new(**raw_book))
    end
  end

  def read_data1
    return unless File.exist?(DATA_STORE1)

    yaml_data = File.read(DATA_STORE1)
    raw_data = Psych.load(yaml_data, symbolize_names: true)
    raw_data[:stationery_list].each do |raw_stationery|
      @stationery_list.add_real_stationery(Stationery.new(**raw_stationery))
    end
  end

  def read_data2
    return unless File.exist?(DATA_STORE2)

    yaml_data = File.read(DATA_STORE2)
    raw_data = Psych.load(yaml_data, symbolize_names: true)
    raw_data[:shopping_list].each do |raw_list|
      list = ShopList.new(raw_list[:id], raw_list[:name])
      raw_data[:book].each do |raw_book|
        list.add_real_product(Book.new(**raw_book))
      end
      raw_data[:stationery].each do |raw_stationery|
        list.add_real_product(Stationery.new(**raw_stationery))
      end
      @shopping_lists.add_list(list)
    end
  end

  def write_data
    raw_books = @book_list.all_books.map(&:to_h)
    yaml_data = Psych.dump({
                             book_list: raw_books
                           })
    File.write(DATA_STORE, yaml_data)
  end

  def write_data1
    raw_stationerys = @stationery_list.all_stationerys.map(&:to_h)
    yaml_data = Psych.dump({
                             stationery_list: raw_stationerys
                           })
    File.write(DATA_STORE1, yaml_data)
  end

  def write_data2
    @shopping_lists.each do |shop_list|
      raw_list = shop_list.name
      yaml_data = Psych.dump({
                               name: raw_list
                             })
      File.write(DATA_STORE2, yaml_data)
      raw_stationerys = @shop_list.all_stationerys.map(&:to_h)
      yaml_data = Psych.dump({
                               stationery: raw_stationerys
                             })
      File.write(DATA_STORE2, yaml_data)
    end
  end
end
