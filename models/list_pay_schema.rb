# frozen_string_literal: true

require 'dry-schema'

ListPaySchema = Dry::Schema.Params do
  required(:name).filled(SchemaTypes::StrippedString)
  required(:confirmation).filled(true)
end
