require_relative "../test_helper"

class StructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = fixture_to_model(users(:one), User)
    @project = fixture_to_model(projects(:one), Project)
    @act = fixture_to_model(acts(:one), Act)
    @sequence = fixture_to_model(sequences(:one), Sequence)
    @scene = fixture_to_model(scenes(:one), Scene)
    sign_in_as(@user)
  end

  test "should get show" do
    get project_structure_path(@project)
    assert_response :success
  end

  test "should reorder acts" do
    act2 = @project.acts.create!(title: "Act 2", description: "Second")
    act3 = @project.acts.create!(title: "Act 3", description: "Third")

    post project_reorder_structure_path(@project), params: {
      type: "act",
      ids: [ act3.id, @act.id, act2.id ]
    }, as: :json

    assert_response :success
    assert_equal true, JSON.parse(response.body)["success"]
  end

  test "should reorder sequences" do
    seq2 = @project.sequences.create!(title: "Seq 2", act: @act)
    seq3 = @project.sequences.create!(title: "Seq 3", act: @act)

    post project_reorder_structure_path(@project), params: {
      type: "sequence",
      ids: [ seq3.id, @sequence.id, seq2.id ]
    }, as: :json

    assert_response :success
    assert_equal true, JSON.parse(response.body)["success"]
  end

  test "should reorder scenes" do
    scene2 = @project.scenes.create!(title: "Scene 2", sequence: @sequence)
    scene3 = @project.scenes.create!(title: "Scene 3", sequence: @sequence)

    post project_reorder_structure_path(@project), params: {
      type: "scene",
      ids: [ scene3.id, @scene.id, scene2.id ]
    }, as: :json

    assert_response :success
    assert_equal true, JSON.parse(response.body)["success"]
  end

  test "should reject reorder with invalid type" do
    post project_reorder_structure_path(@project), params: {
      type: "invalid",
      ids: [ @act.id ]
    }, as: :json

    assert_response :bad_request
  end

  test "should reject reorder with missing parameters" do
    post project_reorder_structure_path(@project), params: {
      type: "act"
    }, as: :json

    assert_response :bad_request
  end

  test "should not access other user's project structure" do
    other_project = projects(:two)

    get project_structure_path(other_project)
    assert_redirected_to projects_path
  end
end
