require_relative "../test_helper"

class CharactersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = fixture_to_model(users(:one), User)
    @project = fixture_to_model(projects(:one), Project)
    @character = fixture_to_model(characters(:one), Character)
    sign_in_as(@user)
  end

  test "should get index" do
    get project_characters_path(@project)
    assert_response :success
  end

  test "should show character" do
    get project_character_path(@project, @character)
    assert_response :success
  end

  test "should get new" do
    get new_project_character_path(@project)
    assert_response :success
  end

  test "should create character" do
    assert_difference("Character.count") do
      post project_characters_path(@project), params: { character: {
        name: "New Character",
        internal_trait_attributes: {
          skills: "Acting",
          main_motivation: "Revenge"
        },
        external_trait_attributes: {
          general_appearance: "Tall and thin",
          profession: "Detective"
        }
      } }
    end

    assert_redirected_to project_character_path(@project, Character.last)
  end

  test "should get edit" do
    get edit_project_character_path(@project, @character)
    assert_response :success
  end

  test "should update character" do
    patch project_character_path(@project, @character), params: { character: { name: "Updated Character" } }
    assert_redirected_to project_character_path(@project, @character)
    @character.reload
    assert_equal "Updated Character", @character.name
  end

  test "should destroy character" do
    assert_difference("Character.count", -1) do
      delete project_character_path(@project, @character)
    end

    assert_redirected_to project_characters_path(@project)
  end

  test "should generate character report PDF" do
    get report_project_character_path(@project, @character)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should generate collection report PDF" do
    get collection_report_project_characters_path(@project)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should not access other user's project characters" do
    other_project = projects(:two)

    get project_characters_path(other_project)
    assert_redirected_to projects_path
  end
end
