lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pgn/version'

Gem::Specification.new do |spec|
  spec.name          = 'pgn'
  spec.version       = PGN::VERSION
  spec.authors       = ['Stacey Touset']
  spec.email         = ['stacey@touset.org']
  spec.description   = 'A PGN parser and FEN generator for Ruby'
  spec.summary       = 'A PGN parser for Ruby'
  spec.homepage      = 'https://github.com/capicue/pgn'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'whittle', '~> 0.0.8'

  spec.add_development_dependency 'bundler', "~> 2.3"
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.11'
end
