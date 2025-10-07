require "test_helper"

class ActsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get acts_index_url
    assert_response :success
  end

  test "should get new" do
    get acts_new_url
    assert_response :success
  end

  test "should get create" do
    get acts_create_url
    assert_response :success
  end

  test "should get edit" do
    get acts_edit_url
    assert_response :success
  end

  test "should get update" do
    get acts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get acts_destroy_url
    assert_response :success
  end
end
