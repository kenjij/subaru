Gem::Specification.new do |s|
  s.name          = "subaru"
  s.version       = "1.0.0"
  s.authors       = ["Ken J."]
  s.email         = ["kenjij@gmail.com"]
  s.description   = %q{RESTful API to industrial web relays}
  s.summary       = %q{RESTful API server gem to industrial web relays.}
  s.homepage      = "https://github.com/kenjij/subaru"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "kajiki", "~> 1.1"
  s.add_runtime_dependency "sinatra", "~> 1.4"
end
