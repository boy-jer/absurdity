# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "absurdity/version"

Gem::Specification.new do |s|
  s.name        = "absurdity"
  s.version     = Absurdity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Tim Payton"
  s.email       = "timpayton@gmail.com"
  s.homepage    = ""
  s.summary     = %q{Absurdly simple a/b testing}
  s.description = %q{See summary}

  s.rubyforge_project = "absurdity"

  s.add_dependency(%q<redis>, [">= 0"])
  s.add_dependency(%q<rake>, ["0.8.7"])
  s.add_development_dependency(%q<mock_redis>, [">= 0"])

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
