require 'ruby_event_store/serialized_record'
require 'active_support/core_ext/object'

module RubyEventStoreEventIdMapper
  class RepositoryWrapper
    def initialize(repository:, serializer:)
      @repository = repository
      @id_mapper = serializer.method(:dump)
      @id_inverter = serializer.method(:load)
      @record_mapper = ->(serialized_record) do
        ::RubyEventStore::SerializedRecord.new(
          event_id: @id_mapper.call(serialized_record.event_id),
          data: serialized_record.data,
          metadata: serialized_record.metadata,
          event_type: serialized_record.event_type,
        )
      end
      @record_inverter = ->(serialized_record) do
        ::RubyEventStore::SerializedRecord.new(
          event_id: @id_inverter.call(serialized_record.event_id),
          data: serialized_record.data,
          metadata: serialized_record.metadata,
          event_type: serialized_record.event_type,
        )
      end
      freeze
    end

    def append_to_stream(events, stream, expected_version)
      transformed_events = Array(events).map(&@record_mapper)
      @repository.append_to_stream(transformed_events, stream, expected_version)
      self
    end

    def link_to_stream(event_ids, stream, expected_version)
      transformed_ids = Array(event_ids).map(&@id_mapper)
      begin
        @repository.link_to_stream(transformed_ids, stream, expected_version)
        self
      rescue ::RubyEventStore::EventNotFound => e
        raise ::RubyEventStore::EventNotFound, @id_inverter.call(e.event_id)
      end
    end

    def delete_stream(stream)
      @repository.delete_stream(stream)
    end

    def has_event?(event_id)
      @repository.has_event?(@id_mapper.call(event_id))
    end

    def last_stream_event(stream)
      event = @repository.last_stream_event(stream)
      event && @record_inverter.call(event)
    end

    def read_event(event_id)
      begin
        @record_inverter.call(@repository.read_event(@id_mapper.call(event_id)))
      rescue ::RubyEventStore::EventNotFound => e
        raise ::RubyEventStore::EventNotFound, @id_inverter.call(e.event_id)
      end
    end

    def read(specification)
      if specification.start.present?
        specification.start = @id_mapper.call(specification.start)
      end
      @repository.read(specification).map(&@record_inverter).each
    end
  end
end
