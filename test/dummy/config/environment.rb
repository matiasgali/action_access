ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)
require 'bundler/setup'
require 'rails/all'

Bundler.require(*Rails.groups)
require "action_access"

module Dummy
  class Application < Rails::Application
    # Allows sessions to be verified against a known secure key to prevent tampering.
    secrets.secret_key_base = 'thisisasecretkey'

    # Don't reload code between tests.
    config.cache_classes = true
    config.cache_store   = :memory_store

    # Test order
    config.active_support.test_order = :random

    # Avoids loading the whole application just for running a single test.
    config.eager_load = false

    # Show full error reports and disable caching.
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Raise exceptions instead of rendering exception templates.
    config.action_dispatch.show_exceptions = false

    # Disable request forgery protection in test environment.
    config.action_controller.allow_forgery_protection = false

    # Print deprecation notices to the stderr.
    config.active_support.deprecation = :stderr
  end
end

# Initialize the Rails application.
Rails.application.initialize!
