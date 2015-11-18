$:.push File.expand_path("../lib", __FILE__)

require "gitlab-backup/version"

Gem::Specification.new do |spec|
  spec.name        = "gitlab-backup"
  spec.version     = Gitlab::Backup::VERSION
  spec.authors     = ["Uwe Kleinmann"]
  spec.email       = "uwe@kleinmann.org"
  spec.homepage    = "https://github.com/kleinmann/gitlab-backup"
  spec.summary     = "A tool to backup repositories from any GitLab installation."
  spec.description = "A tool to backup GitLab repositories to your local machine."
  spec.license     = "ISC"

  spec.executables = "gitlab-backup"

  spec.files = `git ls-files`.split

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rdoc", "~> 4.0"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "redcarpet", "~> 3.2"
end
