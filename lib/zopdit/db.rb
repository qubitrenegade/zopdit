# frozen_string_literal: true

module Zopdit
  # handle DB connections and queries
  # any class that includes this mixin must implement a `table` accessor and set it
  module DB
    # Need to take DB name, and be able to connect to psql too
    def db
      @db ||= db_path
    end

    def db_path
      File.join(Zopdit.root_dir, 'db', 'test.db').then { |s| Sequel.connect "sqlite://#{s}" }
    end

    def ds
      db[table]
    end

    def db_insert(**options)
      ds.insert options
    end

    def parse_dataset(dataset)
      dataset ? Struct.new(*dataset.keys).new(*dataset.values) : nil
    end
  end
end
