require "test_helper"

class StructuresControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get structures_show_url
    assert_response :success
  end

  test "should get reorder" do
    get structures_reorder_url
    assert_response :success
  end
end
