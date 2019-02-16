
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby_event_store_event_id_mapper/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_event_store_event_id_mapper"
  spec.version       = RubyEventStoreEventIdMapper::VERSION
  spec.authors       = ["Sarun Rattanasiri"]
  spec.email         = ["midnight_w@gmx.tw"]

  spec.summary       = %q{Ruby Event Store repository wrapper for id serialization}
  spec.description   = %q{A thin wrapper for Ruby Event Store repository implementations to serialize event_id with external serializers.}
  spec.homepage      = "https://github.com/the-cave/event-id-mapper"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir                = "exe"
  spec.executables           = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths         = ["lib"]
  spec.required_ruby_version = '> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rails', ['> 4.0', '< 6.0']
  spec.add_development_dependency 'rails_event_store_active_record', '~> 0.28.0'
  spec.add_development_dependency 'sqlite3', ['~> 1.3', '< 1.4']
  spec.add_development_dependency 'mysql2', '~> 0.5.1'

  spec.add_dependency 'ruby_event_store', '~> 0.28.0'
  spec.add_dependency 'activesupport', '> 4.0'
end
