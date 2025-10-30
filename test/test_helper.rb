ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to sign in a user for integration tests
    def sign_in_as(user)
      # Get user ID, handling both Hash and ActiveRecord object
      user_id = user.is_a?(Hash) ? (user["id"] || user[:id]) : user.id

      # Ensure we have a User object, not a Hash (can happen in parallel tests)
      user_obj = user.is_a?(Hash) ? User.find(user_id) : user

      # Find or create a session for this user
      # Use ::Session to reference our model, not ActionDispatch::Session
      # In parallel tests, use find_or_create_by to avoid race conditions
      user_session = ::Session.find_or_create_by!(user_id: user_obj.id) do |sess|
        sess.user_agent = "Test Browser"
        sess.ip_address = "127.0.0.1"
      end

      # Directly set in the Rack session store which persists across requests
      post rails_health_check_path, env: { "rack.session" => { session_id: user_session.id } }
    end
  end
end
