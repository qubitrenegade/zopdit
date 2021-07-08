# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :posted, TrueClass
      add_column :to_post, TrueClass
    end
  end
end
