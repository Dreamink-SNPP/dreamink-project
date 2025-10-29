require "test_helper"

class ScenesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @act = acts(:one)
    @sequence = sequences(:one)
    @scene = scenes(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_scenes_path(@project)
    assert_response :success
  end

  test "should show scene" do
    get project_scene_path(@project, @scene)
    assert_response :success
  end

  test "should get new" do
    get new_project_scene_path(@project, sequence_id: @sequence.id)
    assert_response :success
  end

  test "should get new modal" do
    get new_modal_project_scene_path(@project, @scene, sequence_id: @sequence.id)
    assert_response :success
  end

  test "should create scene" do
    assert_difference("Scene.count") do
      post project_scenes_path(@project), params: { scene: {
        title: "New Scene",
        description: "Scene description",
        color: "blue",
        position: 2,
        sequence_id: @sequence.id
      } }
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should get edit" do
    get edit_project_scene_path(@project, @scene)
    assert_response :success
  end

  test "should get edit modal" do
    get edit_modal_project_scene_path(@project, @scene)
    assert_response :success
  end

  test "should update scene" do
    patch project_scene_path(@project, @scene), params: { scene: { title: "Updated Scene" } }
    assert_redirected_to project_structure_path(@project)
    @scene.reload
    assert_equal "Updated Scene", @scene.title
  end

  test "should destroy scene" do
    assert_difference("Scene.count", -1) do
      delete project_scene_path(@project, @scene)
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should get scenes by location" do
    location = @project.locations.first
    get by_location_project_scenes_path(@project, location_id: location.id)
    assert_response :success
  end

  test "should move scene to different sequence" do
    other_sequence = @project.sequences.create!(
      title: "Sequence 2",
      description: "Second sequence",
      position: 2,
      act: @act
    )

    patch move_to_sequence_project_scene_path(@project, @scene), params: {
      target_sequence_id: other_sequence.id,
      target_position: 1
    }

    assert_redirected_to project_structure_path(@project)
    @scene.reload
    assert_equal other_sequence.id, @scene.sequence_id
  end

  test "should not access other user's project scenes" do
    other_project = projects(:two)

    get project_scenes_path(other_project)
    assert_redirected_to projects_path
  end
end
