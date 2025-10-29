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
      session = user.sessions.create!(user_agent: "Test Browser", ip_address: "127.0.0.1")
      # Set Current.session directly for tests since cookies.signed doesn't work in test environment
      Current.session = session
      # Also set the signed cookie using Rails message verifier
      signed_value = Rails.application.message_verifier(:signed_cookie_salt).generate(session.id)
      cookies[:session_id] = signed_value
    end
  end
end
