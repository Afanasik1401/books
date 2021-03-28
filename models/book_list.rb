# frozen_string_literal: true

require_relative 'book'

# The class that contains all our books
class BookList
  def initialize(books = [])
    @books = books.map do |book|
      [book.id, book]
    end.to_h
  end

  def all_books
    @books.values
  end

  def book_by_id(id)
    @books[id]
  end

  def size
    @books.keys.max
  end

  def add_book(parameters)
    book_id = if @books.empty?
                1
              else
                @books.keys.max + 1
              end
    @books[book_id] = Book.new(id: book_id, **parameters.to_h)
    @books[book_id]
  end

  def add_real_book(book)
    @books[book.id] = book
  end

  def update_book(id, parameters)
    book = @books[id]
    parameters.to_h.each do |key, value|
      book[key] = value
    end
  end

  def update_number_book(id, num)
    book = @books[id]
    t = book.number
    book.number = t - num
  end

  def delete_book(id)
    @books.delete(id)
  end

  def number_by_genre(genre)
    number = 0
    @books.select do |_id, book|
      number += 1 if genre == book.genre
    end
    number
  end

  def number_by_name(name)
    number = 0
    @books.select do |_id, book|
      number += book.number if name == book.title
    end
    number
  end

  def average_cost(genre)
    cost = 0
    @books.select do |_id, book|
      cost += book.price if genre == book.genre
    end
    cost
  end

  def amount
    number = 0
    @books.select do |_id, book|
      number += book.number
    end
    number
  end

  def amount_by_genre(genre)
    number = 0
    @books.select do |_id, book|
      number += book.number if genre == book.genre
    end
    number
  end

  def names
    names = []
    @books.select do |_id, book|
      names.append(book.title) if !names.include?(book.title)
    end
    names
  end

  def genres
    names = []
    @books.select do |_id, book|
      names.append(book.genre) if !names.include?(book.genre)
    end
    names
  end

  #   def filter(genre, title)
  #     if genre
  #     @books.select { |id, book| book.genre.match(genre) }.values
  #     else
  #       @books.values
  #   end
  #   if title
  #     @books.select { |id, book| book.title.match(title) }.values
  #     else
  #       @books.values
  #   end
  # end
  def filter(genre, title)
    @books.select do |_id, book|
      next if genre && !genre.empty? && genre != book.genre
      next if title && !title.empty? && !book.title.include?(title)

      true
    end.values
  end
end
