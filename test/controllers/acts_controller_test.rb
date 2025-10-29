require "test_helper"

class ActsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @act = acts(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_acts_path(@project)
    assert_response :success
  end

  test "should get new" do
    get new_project_act_path(@project)
    assert_response :success
  end

  test "should create act" do
    assert_difference("Act.count") do
      post project_acts_path(@project), params: { act: {
        title: "New Act",
        description: "Act description",
        position: 2
      } }
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should get edit" do
    get edit_project_act_path(@project, @act)
    assert_response :success
  end

  test "should get edit modal" do
    get edit_modal_project_act_path(@project, @act)
    assert_response :success
  end

  test "should update act" do
    patch project_act_path(@project, @act), params: { act: { title: "Updated Act" } }
    assert_redirected_to project_structure_path(@project)
    @act.reload
    assert_equal "Updated Act", @act.title
  end

  test "should destroy act" do
    assert_difference("Act.count", -1) do
      delete project_act_path(@project, @act)
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should move act left" do
    # Create another act with lower position
    other_act = @project.acts.create!(title: "Act 0", description: "First", position: 0)
    @act.update!(position: 1)

    patch move_left_project_act_path(@project, @act)
    assert_redirected_to project_structure_path(@project)
  end

  test "should move act right" do
    # Create another act with higher position
    other_act = @project.acts.create!(title: "Act 2", description: "Third", position: 2)
    @act.update!(position: 1)

    patch move_right_project_act_path(@project, @act)
    assert_redirected_to project_structure_path(@project)
  end

  test "should not access other user's project acts" do
    other_project = projects(:two)

    get project_acts_path(other_project)
    assert_redirected_to projects_path
  end
end
