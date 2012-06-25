# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "niceogiri/version"

Gem::Specification.new do |s|
  s.name        = "niceogiri"
  s.version     = Niceogiri::VERSION
  s.authors     = ["Ben Langfeld", "Jeff Smick"]
  s.email       = ["ben@langfeld.me", "sprsquish@gmail.com"]
  s.homepage    = "https://github.com/benlangfeld/Niceogiri"
  s.summary     = %q{Some additional niceties atop Nokogiri}
  s.description = %q{Make dealing with XML less painful}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = %w{--charset=UTF-8}
  s.extra_rdoc_files = %w{LICENSE README.md}

  s.add_dependency "nokogiri", ["~> 1.5"]

  s.add_development_dependency "rspec", ["~> 2.7"]
  s.add_development_dependency "bundler", ["~> 1.0"]
  s.add_development_dependency "yard", ["~> 0.6"]
  s.add_development_dependency "rake"
  s.add_development_dependency "guard-rspec"
end
