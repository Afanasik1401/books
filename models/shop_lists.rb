# frozen_string_literal: true

require_relative 'shop_list'

# The class that contains all our lists
class ShopLists
  def initialize(lists = [])
    @lists = lists.map do |list|
      [list.id, list]
    end.to_h
  end

  def all_lists
    @lists.values
  end

 
  def list_by_id(id)
    @lists[id]
  end

  def list_by_name(name1)
    list1 = nil
    @lists.select do |_id, list|
      list1 = list if list.name == name1
    end
    list1
  end

 
  def add_list(list)
    @lists[list.id] = list
  end

  def size
    @books.keys.max
  end

 
  def all_names
    names = []
    @lists.select do |_id, _list|
      names.append(_list.name)
    end
    names
  end

  def delete_list(id)
    @lists.delete(id)
  end
end
