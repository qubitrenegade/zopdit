# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :id
      String :title, unique: true, index: true
      DateTime :published, index: true
      String :direct_link
      String :post_link
      String :short_description
    end
  end
end
