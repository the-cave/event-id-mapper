# Event ID Mapper

Event ID Mapper is a plug-in for [Rails Event Store (RES)](https://railseventstore.org/) library that let you serialize and control the `event_id` format perceived by [the repository](https://railseventstore.org/docs/repository/).  
Its original purpose is to encode the primary key and the foreign key in binary format for MySQL compatible databases. Leveraging on [ActiveRecord repository](https://github.com/RailsEventStore/rails_event_store/tree/master/rails_event_store_active_record) for the underlying repository implementation.  
However, since the mapper is generic you can easily use it with any Ruby Event Store repository implementations.

## Basic usage

### for ActiveRecord repository and MySQL

When Rails Event Store generates a migration for you. You can edit the migration file to suit your needs.  
For instance:
```ruby
def change
  create_table(:event_store_events, id: :binary, limit: 16, force: false) do |t|
    t.string   :event_type,                                    null: false
    t.binary   :data,       limit: 256.kilobytes,              null: false
    t.binary   :metadata,   limit: 256.kilobytes
    t.datetime :created_at,                       index: true, null: false
  end

  create_table(:event_store_events_in_streams, force: false) do |t|
    t.string   :stream,                                        null: false
    t.integer  :position
    t.binary   :event_id,   limit: 16,            index: true, null: false
    t.datetime :created_at,                       index: true, null: false
  end
  add_index :event_store_events_in_streams, [:stream, :position], unique: true
  add_index :event_store_events_in_streams, [:stream, :event_id], unique: true
end
```
Please note the `limit: 16` addition on the primary and foreign key attributes.  
Now in Ruby code, you can create an `event_store` instance with a custom repository following [the guide](https://railseventstore.org/docs/repository/) on Rails Event Store website letting `RubyEventStoreEventIdMapper::RepositoryWrapper` tap in.
```ruby
event_store = RailsEventStore::Client.new(
  repository: RubyEventStoreEventIdMapper::RepositoryWrapper.new(
    repository: RailsEventStoreActiveRecord::EventRepository.new,
    serializer: RubyEventStoreEventIdMapper::BinaryUUIDSerializer,
  )
)

```
It is recommended that you verify the compatibility of your setup with
[the test suite](https://github.com/RailsEventStore/rails_event_store/blob/master/ruby_event_store/lib/ruby_event_store/spec/event_repository_lint.rb)
provided by Ruby Event Store.  
It is also recommended to see
[how this tiny gem actually works](https://github.com/the-cave/ruby-event-store-event-id-mapper/blob/master/lib/ruby_event_store_event_id_mapper/repository_wrapper.rb).

### for other uses
It is possible that you have a better use case for the mapper but for now, I can't think of any concrete one.

## Code status

[![Build Status](https://semaphoreci.com/api/v1/midnight-wonderer/event-id-mapper/branches/master/shields_badge.svg)](https://semaphoreci.com/midnight-wonderer/event-id-mapper)

## Contributing

Bug reports, pull requests, and inquiries are welcome on [the GitHub repository](https://github.com/the-cave/ruby-event-store-event-id-mapper).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
