# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'action_access/version'

# Gem description and dependencies
Gem::Specification.new do |s|
  s.name          = 'action_access'
  s.version       = ActionAccess::VERSION
  s.authors       = ['Matías A. Gagliano']
  s.email         = ['matias.gagliano@gmail.com']
  s.homepage      = 'https://github.com/matiasgagliano/action_access'
  s.summary       = 'Access control system for Ruby on Rails.'
  s.description   = 'Easy and modular way to secure applications and handle permissions.'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'rails', '~> 4.1'

  s.add_development_dependency 'sqlite3'
end

