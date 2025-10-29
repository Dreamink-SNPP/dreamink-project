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
      user_session = user.sessions.create!(user_agent: "Test Browser", ip_address: "127.0.0.1")

      # Make a request to an unauthenticated endpoint to initialize the session
      # This is necessary because session isn't available until first request in tests
      get rails_health_check_path
      session[:session_id] = user_session.id
    end
  end
end
