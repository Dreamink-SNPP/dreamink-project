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

    # Helper method to convert fixtures to model instances in parallel test mode
    # In parallel tests, fixtures are returned as Hashes instead of AR instances
    def fixture_to_model(fixture, model_class)
      return fixture if fixture.is_a?(model_class)
      return fixture if fixture.is_a?(ActiveRecord::Base)

      # Handle Hash (parallel test mode)
      if fixture.is_a?(Hash)
        id = fixture["id"] || fixture[:id]
        return model_class.find(id) if id
        raise ArgumentError, "Fixture Hash has no id key: #{fixture.inspect}"
      end

      # Handle fixture accessor with respond_to?(:id)
      if fixture.respond_to?(:id)
        return model_class.find(fixture.id)
      end

      # Fallback: raise error
      raise ArgumentError, "Cannot convert fixture to model: #{fixture.class} - #{fixture.inspect}"
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to sign in a user for integration tests
    def sign_in_as(user)
      # Get the user ID, handling both Hash (parallel mode) and model instances
      user_id = if user.is_a?(Hash)
        user["id"] || user[:id]
      elsif user.respond_to?(:id)
        user.id
      else
        raise ArgumentError, "Cannot extract ID from user: #{user.inspect}"
      end

      raise ArgumentError, "User ID cannot be nil. Got: #{user.inspect}" if user_id.nil?

      # Find the actual user model from database (guarantees proper AR instance)
      user_obj = User.find(user_id)

      # Find or create a session for this user
      user_session = ::Session.find_or_create_by!(user_id: user_obj.id) do |sess|
        sess.user_agent = "Test Browser"
        sess.ip_address = "127.0.0.1"
      end

      # Stub the authentication to return this session
      # This works because Authentication concern uses Current.session
      ApplicationController.class_eval do
        def find_session_by_cookie
          # Check if cookies were explicitly cleared in the test
          return nil if cookies[:session_id] == :deleted || cookies[:session_id].nil? && defined?(@cookies_cleared)

          ::Session.find_by(id: Thread.current[:test_session_id])
        end
      end

      Thread.current[:test_session_id] = user_session.id
      @cookies_cleared = false
    end

    # Helper to properly clear authentication in tests
    def clear_authentication
      Thread.current[:test_session_id] = nil
      @cookies_cleared = true
      cookies.delete(:session_id)
    end
  end
end
