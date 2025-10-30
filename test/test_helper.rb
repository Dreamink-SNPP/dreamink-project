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
      # Handle both fixture reference (Hash) and User object
      user_obj = if user.is_a?(Hash)
        # In parallel tests, fixtures are accessed as Hashes
        # Try both string and symbol keys
        user_id = user["id"] || user[:id]

        if user_id.nil?
          raise ArgumentError, "Fixture hash must contain 'id' or :id key. Got: #{user.inspect}"
        end

        User.find(user_id)
      elsif user.is_a?(User)
        user
      else
        # Handle fixture name as symbol: users(:one)
        # This shouldn't happen but just in case
        User.find(user.id)
      end

      # Find or create a session for this user
      user_session = ::Session.find_or_create_by!(user_id: user_obj.id) do |sess|
        sess.user_agent = "Test Browser"
        sess.ip_address = "127.0.0.1"
      end

      # Set session in Rack session store
      post rails_health_check_path, env: { "rack.session" => { session_id: user_session.id } }
    end
  end
end
