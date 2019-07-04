# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :posted, TrueClass
      add_column :skip_posting, TrueClass
    end
    from(:posts).update(posted: false)
    from(:posts).update(skip_posting: true)
  end
end
