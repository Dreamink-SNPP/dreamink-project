require_relative "../test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = fixture_to_model(users(:one), User)
    @project = fixture_to_model(projects(:one), Project)
    sign_in_as(@user)
  end

  test "should get index" do
    get projects_path
    assert_response :success
  end

  test "should get new" do
    get new_project_path
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_path, params: { project: {
        title: "New Project",
        genre: "Drama",
        idea: "A story about...",
        logline: "A compelling logline"
      } }
    end

    assert_redirected_to project_path(Project.last)
  end

  test "should show project" do
    get project_path(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_path(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_path(@project), params: { project: { title: "Updated Title" } }
    assert_redirected_to project_path(@project)
    @project.reload
    assert_equal "Updated Title", @project.title
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_path(@project)
    end

    assert_redirected_to projects_path
  end

  test "should generate project report PDF" do
    get report_project_path(@project)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should redirect to login when not authenticated" do
    # Clear authentication
    clear_authentication

    get projects_path
    assert_redirected_to new_session_path
  end

  test "should not access other user's project" do
    other_user = users(:two)
    other_project = projects(:two)

    get project_path(other_project)
    assert_redirected_to projects_path
  end
end
