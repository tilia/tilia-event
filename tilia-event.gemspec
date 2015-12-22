require File.join(File.dirname(__FILE__), 'lib', 'tilia', 'event', 'version')
Gem::Specification.new do |s|
  s.name        = 'tilia-event'
  s.version     = Tilia::Event::Version::VERSION
  s.licenses    = ['BSD-3-Clause']
  s.summary     = 'Port of the sabre-event library to ruby'
  s.description = 'tilia_event is a library for lightweight event-based programming.'
  s.author      = 'Jakob Sack'
  s.email       = 'tiliadav@jakobsack.de'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://rubygems.org/gems/tilia-event'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
end
