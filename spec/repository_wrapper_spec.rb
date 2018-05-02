require 'ruby_event_store'
require 'ruby_event_store/spec/event_repository_lint'
require 'rails_event_store_active_record'

RSpec.describe RubyEventStoreEventIdMapper do
  it "has a version number" do
    expect(RubyEventStoreEventIdMapper::VERSION).not_to be nil
  end
end

module RubyEventStoreEventIdMapper
  RSpec.describe RepositoryWrapper do
    include SchemaHelper

    around(:each) do |example|
      begin
        establish_database_connection
        load_database_schema
        example.run
      ensure
        drop_database
      end
    end

    let(:test_race_conditions_auto) {!ENV['DATABASE_URL'].include?('sqlite')}
    let(:test_race_conditions_any) {!ENV['DATABASE_URL'].include?('sqlite')}
    let(:test_binary) {true}
    let(:test_expected_version_auto) {true}
    let(:test_link_events_to_stream) {true}
    let(:test_non_legacy_all_stream) {true}
    let(:migrate_to_binary) {->() {nil}}

    subject do
      RepositoryWrapper.new(
        repository: ::RailsEventStoreActiveRecord::EventRepository.new,
        serializer: BinaryUUIDSerializer,
      )
    end

    it_should_behave_like :event_repository
  end
end
