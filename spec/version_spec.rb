module RubyEventStoreEventIdMapper
  RSpec.describe 'version number' do
    it 'has a correct semver format' do
      expect(VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end
end
