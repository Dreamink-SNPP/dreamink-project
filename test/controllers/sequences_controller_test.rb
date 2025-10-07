require "test_helper"

class SequencesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sequences_index_url
    assert_response :success
  end

  test "should get new" do
    get sequences_new_url
    assert_response :success
  end

  test "should get create" do
    get sequences_create_url
    assert_response :success
  end

  test "should get edit" do
    get sequences_edit_url
    assert_response :success
  end

  test "should get update" do
    get sequences_update_url
    assert_response :success
  end

  test "should get destroy" do
    get sequences_destroy_url
    assert_response :success
  end
end
