# frozen_string_literal: true

# Routes for the cool books of this application
class BookApplication
  path :all, '/all'
  path :all_lists, '/all/lists'
  path :all_books, '/all/cool_books'
  path :list_new, '/all/lists/new'
  path :book_new, '/all/cool_books/new'
  path :stationery_new, '/all/stationerys/new'
  path :all_stationery, '/all/stationerys'
  path Book do |book, action|
    if action
      "/all/cool_books/#{book.id}/#{action}"
    else
      "/all/cool_books/#{book.id}"
    end
  end

  path ShopList do |list, action, id|
    if id
      "/all/lists/#{list.id}/#{id}/#{action}"
    elsif action
      "/all/lists/#{list.id}/#{action}"
    else
      "/all/lists/#{list.id}"
    end
  end
  path Stationery do |stationery, action|
    if action
      "/all/stationerys/#{stationery.id}/#{action}"
    else
      "/all/stationerys/#{stationery.id}"
    end
  end
  hash_branch('all') do |r|
    set_layout_options(template: '../views/layout')
    r.is do
      @books = opts[:books]
      @stationerys = opts[:stationerys]
      view('all_products/all')
    end
    r.on 'lists' do
      # append_view_subdir('all_products')
      r.is do
        @lists = opts[:lists].all_lists
        view('all_products/shopping_lists')
      end
      r.on 'new' do
        append_view_subdir('all_products')
        r.get do
          @parameters = {}
          view('all_products/list_new')
        end
        r.post do
          @parameters = DryResultFormeWrapper.new(ListFormSchema.call(r.params))
          if @parameters.success? && !opts[:lists].all_names.include?(@parameters[:name])
            list_id = if opts[:lists].all_lists.empty?
                        1
                      else
                        opts[:lists].all_lists.size + 1
                      end
            lists = ShopList.new(list_id, @parameters[:name])
            opts[:lists].add_list(lists)

            r.redirect(all_lists_path)
          elsif opts[:lists].all_names.include?(@parameters[:name])
            view('all_products/error_name')
          else
            view('all_products/list_new')
          end
        end
      end
      r.on Integer do |id|
        @lists = opts[:lists].list_by_id(id)
        next if @lists.nil?

        r.is do
          @names = opts[:lists].list_by_id(id).names
          # @lists = opts[:lists].list_by_name(name)
          view('all_products/list')
        end

        r.on 'delete' do
          r.get do
            @parameters = {}
            view('all_products/list_delete')
          end
          r.post do
            # @lists =opts[:lists].list_by_name(name)
            @parameters = DryResultFormeWrapper.new(BookDeleteSchema.call(r.params))
            if @parameters.success?
              opts[:lists].delete_list(@lists.id)
              r.redirect(all_lists_path)
            else
              view('all_products/list_delete')
            end
          end
        end
        r.on 'pay' do
          r.get do
            @names = opts[:lists].list_by_id(id).names
            @parameters = {}
            view('all_products/list_pay')
          end
          r.post do
            @names = opts[:lists].list_by_id(id).names
            @parameters = DryResultFormeWrapper.new(ListPaySchema.call(r.params))
            if @parameters.success?
              file = File.new("db/#{@parameters[:name]}.txt", 'a:UTF-8')
              file.print("Ваш список покупочек\n\r")
              @lists.names.each do |name1|
                file.print("#{name1}: #{@lists.number_by_name(name1)}\r")
              end
              price = 0
              (1..@lists.all_products.size).each do |i|
                price += @lists.product_by_id(i).price if @lists.product_by_id(i)
              end
              file.print(" \n Общая стоимость: #{price}   \n\r")
              file.close
              @lists.all_products.each do |product|
                if product.class == Book
                  opts[:books].update_number_book(product.id, 1)
                elsif product.class == Stationery
                  opts[:stationerys].update_number_stationery(product.id, 1)
                end
              end
              @names.each do |name|
                opts[:lists].all_lists.each do |list|
                  if list.names.include?(name)
                    if opts[:books].names.include?(name) && (list.number_by_name(name) > opts[:books].number_by_name(name))
                      list.delete_product_by_name(name, (list.number_by_name(name) - opts[:books].number_by_name(name)))
                    elsif opts[:stationerys].names.include?(name) && (list.number_by_name(name) > opts[:stationerys].number_by_name(name))
                      list.delete_product_by_name(name, (list.number_by_name(name) - opts[:stationerys].number_by_name(name)))
                    end
                  end
                end
              end
              opts[:lists].delete_list(@lists.id)
              r.redirect(all_lists_path)
            else
              view('all_products/list_pay')
            end
          end
        end
        r.on Integer do |id|
          @product = @lists.product_by_id(id)
          next if @product.nil?

          r.on 'inf' do
            view('all_products/product')
          end

          r.on 'del' do
            r.get do
              @parameters = {}
              view('all_products/product_del')
            end
            r.post do
              @parameters = DryResultFormeWrapper.new(BookDeleteSchema.call(r.params))
              if @parameters.success?
                @lists.delete_product(id)
                r.redirect(path(@lists))
              else
                view('all_products/product_del')
              end
            end
          end
        end
      end
    end

    r.on 'stationerys' do
      # append_view_subdir('stationery')
      @stationerys = opts[:stationerys].all_stationerys
      r.is do
        view('stationery/stationerys')
      end
      r.on 'new' do
        append_view_subdir('stationery')
        r.get do
          @parameters = {}
          view('stationery/stationery_new')
        end
        r.post do
          @parameters = DryResultFormeWrapper.new(StationeryFormSchema.call(r.params))
          if @parameters.success? && !opts[:stationerys].names.include?(@parameters[:title])
            stationery = opts[:stationerys].add_stationery(@parameters)
            r.redirect(path(stationery))
          elsif opts[:stationerys].names.include?(@parameters[:title])
            view('stationery/error_name')
          else
            view('stationery/stationery_new')
          end
        end
      end

      r.on Integer do |stationery_id|
        @stationery = opts[:stationerys].stationery_by_id(stationery_id)
        next if @stationery.nil?

        r.is do
          view('stationery/stationery')
        end

        r.on 'add' do
          append_view_subdir('stationery')
          r.get do
            @names = opts[:lists].all_names
            if @names.empty?
              @lists = opts[:lists].all_lists
              view('all_products/shopping_lists')
            else
              @parameters = {}
              view('stationery/stationery_add')
            end
          end
          r.post do
            @parameters = DryResultFormeWrapper.new(StationeryAddFormSchema.call(r.params))
            if @parameters.success? && (opts[:lists].list_by_name(@parameters[:name]).number_by_name(@stationery.title) <= opts[:stationerys].number_by_name(@stationery.title))
              opts[:lists].list_by_name(@parameters[:name]).add_products(@stationery)
              r.redirect(path(@stationery))
            elsif opts[:lists].list_by_name(@parameters[:name]).number_by_name(@stationery.title) > opts[:stationerys].number_by_name(@stationery.title)
              view('stationery/end_of_stationerys')
            else
              view('stationery/stationery_add')
            end
          end
        end

        r.on 'edit' do
          append_view_subdir('stationery')
          r.get do
            @parameters = @stationery.to_h
            view('stationery/stationery_edit')
          end
          r.post do
            @parameters = DryResultFormeWrapper.new(StationeryFormSchema.call(r.params))
            if @parameters.success?
              opts[:stationerys].update_stationery(@stationery.id, @parameters)
              r.redirect(path(@stationery))
            else
              view('stationery/stationery_edit')
            end
          end
        end
        r.on 'delete' do
          append_view_subdir('stationery')
          r.get do
            @parameters = {}
            view('stationery/stationery_delete')
          end
          r.post do
            @parameters = DryResultFormeWrapper.new(BookDeleteSchema.call(r.params))
            if @parameters.success?
              opts[:stationerys].delete_stationery(@stationery.id)
              r.redirect(all_stationery_path)
            else
              view('stationery/stationery_delete')
            end
          end
        end
      end
    end

    r.on 'cool_books' do
      # append_view_subdir('books')
      #  @books = opts[:books].all_books

      r.is do
        @params = DryResultFormeWrapper.new(BookFilterFormSchema.call(r.params))
        @books =  if @params.success?
                    opts[:books].filter(@params[:genre], @params[:title])
                  else
                    opts[:books].all_books
                  end
        view('books/books')
      end
      r.on 'new' do
        append_view_subdir('books')
        r.get do
          @parameters = {}
          view('books/book_new')
        end
        r.post do
          @parameters = DryResultFormeWrapper.new(BookFormSchema.call(r.params))
          if @parameters.success? && !opts[:books].names.include?(@parameters[:title])
            book = opts[:books].add_book(@parameters)
            r.redirect(path(book))
          elsif opts[:books].names.include?(@parameters[:title])
            view('books/error_name')
          else
            view('books/book_new')
          end
        end
      end
      r.on Integer do |book_id|
        @book = opts[:books].book_by_id(book_id)
        next if @book.nil?

        r.is do
          view('books/book')
        end
        r.on 'add' do
          append_view_subdir('books')
          r.get do
            @names = opts[:lists].all_names
            if @names.empty?
              @lists = opts[:lists].all_lists
              view('all_products/shopping_lists')
            else
              @parameters = {}
              view('books/book_add')
            end
          end
          r.post do
            @parameters = DryResultFormeWrapper.new(StationeryAddFormSchema.call(r.params))
            if @parameters.success? && (opts[:lists].list_by_name(@parameters[:name]).number_by_name(@book.title) <= opts[:books].number_by_name(@book.title))
              opts[:lists].list_by_name(@parameters[:name]).add_products(@book)
              r.redirect(path(@book))
            elsif opts[:lists].list_by_name(@parameters[:name]).number_by_name(@book.title) > opts[:books].number_by_name(@book.title)
              view('books/end_of_book')
            else
              view('books/book_add')
            end
          end
        end

        r.on 'edit' do
          append_view_subdir('books')
          r.get do
            @parameters = @book.to_h
            view('books/book_edit')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(BookFormSchema.call(r.params))
            if @parameters.success?
              opts[:books].update_book(@book.id, @parameters)
              r.redirect(path(@book))
            else
              view('books/book_edit')
            end
          end
        end

        r.on 'delete' do
          append_view_subdir('books')
          r.get do
            @parameters = {}
            view('books/book_delete')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(BookDeleteSchema.call(r.params))
            if @parameters.success?
              opts[:books].delete_book(@book.id)
              r.redirect(all_books_path)
            else
              view('books/book_delete')
            end
          end
        end
      end
    end
  end
end
