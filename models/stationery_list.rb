# frozen_string_literal: true

require_relative 'stationery'

# The class that contains all our stationery
class StationeryList
  def initialize(stationerys = [])
    @stationerys = stationerys.map do |stationery|
      [stationery.id, stationery]
    end.to_h
  end

  def amount
    number = 0
    @stationerys.select do |_id, stationery|
      number += stationery.number
    end
    number
  end

  def all_stationerys
    @stationerys.values
  end

  def stationery_by_id(id)
    @stationerys[id]
  end

  def number_by_name(name)
    number = 0
    @stationerys.select do |_id, stationery|
      number += stationery.number if name == stationery.title
    end
    number
  end

  def add_stationery(parameters)
    stationery_id = if @stationerys.empty?
                      1
                    else
                      @stationerys.keys.max + 1
                    end
    @stationerys[stationery_id] = Stationery.new(id: stationery_id, **parameters.to_h)
    @stationerys[stationery_id]
  end



  def names
    names = []
    @stationerys.select do |_id, stationery|
      names.append(stationery.title) if !names.include?(stationery.title)
    end
    names
  end

  def add_real_stationery(stationery)
    @stationerys[stationery.id] = stationery
  end

  def update_stationery(id, parameters)
    stationery = @stationerys[id]
    parameters.to_h.each do |key, value|
      stationery[key] = value
    end
  end

  def update_number_stationery(id, num)
    stationery = @stationerys[id]
    t = stationery.number
    stationery.number = t - num
  end

  def delete_stationery(id)
    @stationerys.delete(id)
  end
end
