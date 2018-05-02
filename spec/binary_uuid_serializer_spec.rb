module RubyEventStoreEventIdMapper
  RSpec.describe BinaryUUIDSerializer do
    let(:sample_uuid) { SecureRandom.uuid }
    let(:dumped_uuid) { BinaryUUIDSerializer.dump(sample_uuid) }
    let(:loaded_uuid) { BinaryUUIDSerializer.load(dumped_uuid) }

    it 'can serialize a uuid into a compact representation' do
      expect(dumped_uuid.size).to eq(16)
    end

    it 'can deserialize a compact representation of uuid to its original form' do
      expect(loaded_uuid).to eq(sample_uuid)
    end
  end
end
