module Blogging
  class Tag < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :label, :string, max_size: 255

    with_timestamp_fields
  end
end
