require 'bundler/setup'
require 'ruby_event_store_event_id_mapper'
require 'support/rspec_defaults'
require 'active_record'
require 'active_support/core_ext/numeric/bytes'

ENV['DATABASE_URL'] ||= 'sqlite3:db.sqlite3'

module SchemaHelper
  def establish_database_connection
    ::ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end

  def load_database_schema
    migration_class = Class.new(::ActiveRecord::Migration[
      "#{::ActiveRecord::VERSION::MAJOR}.#{::ActiveRecord::VERSION::MINOR}"
    ]) do
      def change
        create_table(:event_store_events_in_streams, force: false) do |t|
          t.string :stream, null: false
          t.integer :position, null: true
          t.binary :event_id, limit: 16, index: true, null: false
          t.datetime :created_at, index: true, null: false
        end
        add_index :event_store_events_in_streams, [:stream, :position], unique: true
        add_index :event_store_events_in_streams, [:stream, :event_id], unique: true

        create_table(:event_store_events, id: false, force: false) do |t|
          t.binary :id, limit: 16, index: { unique: true }, null: false
          t.string :event_type, null: false
          t.binary :data, limit: 64.kilobytes, null: false
          t.binary :metadata, limit: 64.kilobytes
          t.datetime :created_at, index: true, null: false
        end
      end
    end
    ::ActiveRecord::Schema.define do
      self.verbose = false
      migration_class.new.change
    end
  end

  def drop_database
    ::ActiveRecord::Migration.drop_table('event_store_events')
    ::ActiveRecord::Migration.drop_table('event_store_events_in_streams')
  end
end

RSpec.configure do |config|
  config.failure_color = :magenta
end
