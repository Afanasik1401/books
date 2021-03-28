# frozen_string_literal: true

require 'dry-schema'

BookFilterFormSchema = Dry::Schema.Params do
  optional(:genre).maybe(:string)
  optional(:title).maybe(:string)
end
