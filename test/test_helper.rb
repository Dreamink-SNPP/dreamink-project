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
    # Store the session ID for this test (avoid 'test_' prefix which Rails interprets as a test method)
    attr_accessor :current_session_id

    # Helper method to sign in a user for integration tests
    def sign_in_as(user)
      user_session = user.sessions.create!(user_agent: "Test Browser", ip_address: "127.0.0.1")
      @current_session_id = user_session.id

      # Make a request to initialize the session first
      get rails_health_check_path

      # Now set the session_id - this should persist across subsequent requests
      session[:session_id] = @current_session_id
    end

    # Override process to always include session data
    def process(method, path, **args)
      # Inject session data into every request if we have a current_session_id
      if @current_session_id
        args[:env] ||= {}
        args[:env]["rack.session"] ||= {}
        args[:env]["rack.session"][:session_id] = @current_session_id
      end
      super
    end
  end
end
