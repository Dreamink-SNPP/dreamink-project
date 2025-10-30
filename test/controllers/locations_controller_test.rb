require_relative "../test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @location = locations(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_locations_path(@project)
    assert_response :success
  end

  test "should get index filtered by interior" do
    get project_locations_path(@project, type: "interior")
    assert_response :success
  end

  test "should get index filtered by exterior" do
    get project_locations_path(@project, type: "exterior")
    assert_response :success
  end

  test "should show location" do
    get project_location_path(@project, @location)
    assert_response :success
  end

  test "should get new" do
    get new_project_location_path(@project)
    assert_response :success
  end

  test "should create location" do
    assert_difference("Location.count") do
      post project_locations_path(@project), params: { location: {
        name: "New Location",
        description: "A beautiful place",
        location_type: "exterior"
      } }
    end

    assert_redirected_to project_locations_path(@project)
  end

  test "should get edit" do
    get edit_project_location_path(@project, @location)
    assert_response :success
  end

  test "should update location" do
    patch project_location_path(@project, @location), params: { location: { name: "Updated Location" } }
    assert_redirected_to project_locations_path(@project)
    @location.reload
    assert_equal "Updated Location", @location.name
  end

  test "should destroy location" do
    assert_difference("Location.count", -1) do
      delete project_location_path(@project, @location)
    end

    assert_redirected_to project_locations_path(@project)
  end

  test "should generate location report PDF" do
    get report_project_location_path(@project, @location)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should generate collection report PDF" do
    get collection_report_project_locations_path(@project)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should not access other user's project locations" do
    other_project = projects(:two)

    get project_locations_path(other_project)
    assert_redirected_to projects_path
  end
end
