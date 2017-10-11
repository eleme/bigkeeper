# -*- encoding: utf-8 -*-
# stub: big_stash 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "big_stash".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["mmoaay".freeze]
  s.date = "2017-09-28"
  s.description = "Enhancement for git stash that you can give a name to the stash.".freeze
  s.email = ["mmoaay@sina.com".freeze]
  s.executables = ["big-stash".freeze, "setup".freeze]
  s.files = ["bin/big-stash".freeze, "bin/setup".freeze]
  s.homepage = "https://github.com/mmoaay/big-stash".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.13".freeze
  s.summary = "Enhancement for git stash.".freeze

  s.installed_by_version = "2.6.13" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.15"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<gli>.freeze, ["~> 2.16"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.15"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<gli>.freeze, ["~> 2.16"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.15"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<gli>.freeze, ["~> 2.16"])
  end
end
