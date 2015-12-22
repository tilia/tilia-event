require File.join(File.dirname(__FILE__), 'lib', 'tilia', 'event', 'version')
Gem::Specification.new do |s|
  s.name        = 'tilia-event'
  s.version     = Tilia::Event::Version::VERSION
  s.licenses    = ['BSD-3-Clause']
  s.summary     = 'Port of the sabre-event library to ruby'
  s.description = 'tilia-event is a library for lightweight event-based programming.'
  s.author      = 'Jakob Sack'
  s.email       = 'tilia@jakobsack.de'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/tilia/tilia-event'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
end
