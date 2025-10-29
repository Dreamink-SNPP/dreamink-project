require "test_helper"

class SequencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @act = acts(:one)
    @sequence = sequences(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_sequences_path(@project)
    assert_response :success
  end

  test "should get new" do
    get new_project_sequence_path(@project, act_id: @act.id)
    assert_response :success
  end

  test "should get new modal" do
    get new_sequence_modal_project_act_path(@project, @act)
    assert_response :success
  end

  test "should create sequence" do
    assert_difference("Sequence.count") do
      post project_sequences_path(@project), params: { sequence: {
        title: "New Sequence",
        description: "Sequence description",
        position: 2,
        act_id: @act.id
      } }
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should get edit" do
    get edit_project_sequence_path(@project, @sequence)
    assert_response :success
  end

  test "should get edit modal" do
    get edit_modal_project_sequence_path(@project, @sequence)
    assert_response :success
  end

  test "should update sequence" do
    patch project_sequence_path(@project, @sequence), params: { sequence: { title: "Updated Sequence" } }
    assert_redirected_to project_structure_path(@project)
    @sequence.reload
    assert_equal "Updated Sequence", @sequence.title
  end

  test "should destroy sequence" do
    assert_difference("Sequence.count", -1) do
      delete project_sequence_path(@project, @sequence)
    end

    assert_redirected_to project_structure_path(@project)
  end

  test "should move sequence to different act" do
    other_act = @project.acts.create!(title: "Act 2", description: "Second act", position: 2)

    patch move_to_act_project_sequence_path(@project, @sequence), params: {
      target_act_id: other_act.id,
      target_position: 1
    }

    assert_redirected_to project_structure_path(@project)
    @sequence.reload
    assert_equal other_act.id, @sequence.act_id
  end

  test "should not access other user's project sequences" do
    other_project = projects(:two)

    get project_sequences_path(other_project)
    assert_redirected_to projects_path
  end
end
