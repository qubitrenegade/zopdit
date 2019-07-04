# frozen_string_literal: true

Sequel.migration do
  up do
    from(:posts).update(posted: false)
    from(:posts).update(to_post: false)
  end
end
