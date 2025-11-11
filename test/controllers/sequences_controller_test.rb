require_relative "../test_helper"

class SequencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = fixture_to_model(users(:one), User)
    @project = fixture_to_model(projects(:one), Project)
    @act = fixture_to_model(acts(:one), Act)
    @sequence = fixture_to_model(sequences(:one), Sequence)
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
    get project_act_new_sequence_modal_path(@project, @act)
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
    other_act = @project.acts.create!(title: "Act 2", description: "Second act")

    patch move_to_act_project_sequence_path(@project, @sequence), params: {
      target_act_id: other_act.id,
      target_position: 1
    }, as: :turbo_stream

    assert_response :redirect
    @sequence.reload
    assert_equal other_act.id, @sequence.act_id
  end

  test "should move sequence left (up)" do
    # Get the second sequence from fixtures (at position 2)
    sequence_two = fixture_to_model(sequences(:two), Sequence)

    # Store original positions
    original_pos = sequence_two.position

    # Move sequence_two left (up) to swap with @sequence
    patch move_left_project_sequence_path(@project, sequence_two)
    assert_redirected_to project_structure_path(@project)

    # Verify it moved up
    sequence_two.reload
    assert_equal original_pos - 1, sequence_two.position
  end

  test "should move sequence right (down)" do
    # Get the second sequence from fixtures (at position 2)
    sequence_two = fixture_to_model(sequences(:two), Sequence)

    # Store original positions
    original_pos = @sequence.position

    # Move @sequence right (down) to swap with sequence_two
    patch move_right_project_sequence_path(@project, @sequence)
    assert_redirected_to project_structure_path(@project)

    # Verify it moved down
    @sequence.reload
    assert_equal original_pos + 1, @sequence.position
  end

  test "should not move first sequence left" do
    # Ensure @sequence is at position 1
    @sequence.update(position: 1)

    patch move_left_project_sequence_path(@project, @sequence), as: :html
    assert_redirected_to project_structure_path(@project)
  end

  test "should not move last sequence right" do
    # @sequence is the only sequence, so moving right should fail
    patch move_right_project_sequence_path(@project, @sequence), as: :html
    assert_redirected_to project_structure_path(@project)
  end

  test "should not access other user's project sequences" do
    other_project = projects(:two)

    get project_sequences_path(other_project)
    assert_redirected_to projects_path
  end
end
