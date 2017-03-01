Gem::Specification.new do |s|
  s.name     = "bridgeu-rjson"
  s.version  = "0.0.1"
  s.licenses = ['MIT']
  s.summary  = "BridgeU Racc powered JSON parser"
  s.author   = "Sam Jewell"
  s.email    = "sam@bridge-u.com"
  s.files    = Dir["lib/**/*"] & `git ls-files -z`.split("\0")

  s.add_dependency 'racc'
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "hoe"
  s.add_development_dependency "hoe-gemspec"
  s.add_development_dependency "hoe-git"
  s.add_development_dependency "minitest"
  s.add_development_dependency "pry-byebug"

  s.require_paths = ['lib']  
end