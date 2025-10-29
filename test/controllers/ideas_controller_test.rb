require "test_helper"

class IdeasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @idea = ideas(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_ideas_path(@project)
    assert_response :success
  end

  test "should get index filtered by tag" do
    get project_ideas_path(@project, tag: "action")
    assert_response :success
  end

  test "should get new" do
    get new_project_idea_path(@project)
    assert_response :success
  end

  test "should create idea" do
    assert_difference("Idea.count") do
      post project_ideas_path(@project), params: { idea: {
        title: "New Idea",
        description: "A brilliant concept",
        tags: "action, thriller"
      } }
    end

    assert_redirected_to project_ideas_path(@project)
  end

  test "should get edit" do
    get edit_project_idea_path(@project, @idea)
    assert_response :success
  end

  test "should update idea" do
    patch project_idea_path(@project, @idea), params: { idea: { title: "Updated Idea" } }
    assert_redirected_to project_ideas_path(@project)
    @idea.reload
    assert_equal "Updated Idea", @idea.title
  end

  test "should destroy idea" do
    assert_difference("Idea.count", -1) do
      delete project_idea_path(@project, @idea)
    end

    assert_redirected_to project_ideas_path(@project)
  end

  test "should search ideas" do
    get search_project_ideas_path(@project, q: "test")
    assert_response :success
  end

  test "should search ideas with empty query" do
    get search_project_ideas_path(@project)
    assert_response :success
  end

  test "should not access other user's project ideas" do
    other_project = projects(:two)

    get project_ideas_path(other_project)
    assert_redirected_to projects_path
  end
end
