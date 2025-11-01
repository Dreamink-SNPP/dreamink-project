require_relative "../../test_helper"

module Fountain
  class StructureExporterTest < ActiveSupport::TestCase
    setup do
      @user = fixture_to_model(users(:one), User)
      @project = fixture_to_model(projects(:one), Project)
      # Clear any existing acts from fixtures
      @project.acts.destroy_all
    end

    test "should generate Fountain format for project structure" do
      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_not_nil fountain_content
      assert fountain_content.is_a?(String)
      assert_includes fountain_content, "Title: #{@project.title}"
    end

    test "should export acts with sections" do
      act = @project.acts.create!(
        title: "Act One",
        description: "The beginning of the story",
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "# Act One"
      assert_includes fountain_content, "= The beginning of the story"
    end

    test "should export nested structure with acts, sequences, and scenes" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(
        title: "Opening Sequence",
        description: "Introduction to the world",
        project: @project,
        position: 1
      )
      scene = sequence.scenes.create!(
        title: "First Scene",
        description: "The hero appears",
        project: @project,
        act: act,
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "# Act One"
      assert_includes fountain_content, "## Opening Sequence"
      assert_includes fountain_content, "= Introduction to the world"
      assert_includes fountain_content, "### First Scene"
      assert_includes fountain_content, "= The hero appears"
    end

    test "should handle multi-line descriptions as paragraphs" do
      act = @project.acts.create!(
        title: "Act Two",
        description: "This is the first line.\nThis is the second line.\nThis is the third line.",
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "# Act Two"
      # Multi-line descriptions should not use synopsis syntax
      assert_not_includes fountain_content, "= This is the first line."
      # But should include the lines as regular paragraphs
      assert_includes fountain_content, "This is the first line."
      assert_includes fountain_content, "This is the second line."
    end

    test "should handle single-line descriptions as synopsis" do
      act = @project.acts.create!(
        title: "Act Three",
        description: "The climactic conclusion",
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "# Act Three"
      assert_includes fountain_content, "= The climactic conclusion"
    end

    test "should handle empty descriptions gracefully" do
      act = @project.acts.create!(title: "Act Four", description: nil, position: 1)
      sequence = act.sequences.create!(
        title: "Sequence Without Description",
        description: "",
        project: @project,
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "# Act Four"
      assert_includes fountain_content, "## Sequence Without Description"
      assert_not_includes fountain_content, "= "
    end

    test "should maintain hierarchical order" do
      act1 = @project.acts.create!(title: "Act One", position: 1)
      act2 = @project.acts.create!(title: "Act Two", position: 2)
      seq1 = act1.sequences.create!(title: "Sequence A", project: @project, position: 1)
      seq2 = act1.sequences.create!(title: "Sequence B", project: @project, position: 2)

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      # Check that Act One comes before Act Two
      act_one_pos = fountain_content.index("# Act One")
      act_two_pos = fountain_content.index("# Act Two")
      assert act_one_pos < act_two_pos

      # Check that Sequence A comes before Sequence B
      seq_a_pos = fountain_content.index("## Sequence A")
      seq_b_pos = fountain_content.index("## Sequence B")
      assert seq_a_pos < seq_b_pos
    end

    test "should generate proper Fountain scene heading with interior location" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(name: "Coffee Shop", location_type: "interior")
      scene = sequence.scenes.create!(
        title: "Opening Scene",
        description: "Characters meet",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "### Opening Scene"
      assert_includes fountain_content, "INT. Coffee Shop"
    end

    test "should generate proper Fountain scene heading with exterior location" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(name: "Downtown Street", location_type: "exterior")
      scene = sequence.scenes.create!(
        title: "Chase Scene",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "### Chase Scene"
      assert_includes fountain_content, "EXT. Downtown Street"
    end

    test "should generate scene heading with time of day" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(name: "Apartment", location_type: "interior")
      scene = sequence.scenes.create!(
        title: "Morning Scene",
        time_of_day: "MORNING",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "INT. Apartment - MORNING"
    end

    test "should generate scene heading with multiple locations" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location1 = @project.locations.create!(name: "Living Room", location_type: "interior")
      location2 = @project.locations.create!(name: "Kitchen", location_type: "interior")
      scene = sequence.scenes.create!(
        title: "House Scene",
        time_of_day: "DAY",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location1
      scene.locations << location2

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "INT. Living Room/Kitchen - DAY"
    end

    test "should generate scene heading with mixed interior and exterior locations" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location1 = @project.locations.create!(name: "Apartment", location_type: "interior")
      location2 = @project.locations.create!(name: "Street", location_type: "exterior")
      scene = sequence.scenes.create!(
        title: "Mixed Scene",
        time_of_day: "NIGHT",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location1
      scene.locations << location2

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "INT/EXT. Apartment/Street - NIGHT"
    end

    test "should only show section heading when scene has no locations" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      scene = sequence.scenes.create!(
        title: "Scene Without Location",
        description: "Scene description",
        project: @project,
        act: act,
        position: 1
      )

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "### Scene Without Location"
      assert_not_includes fountain_content, "INT."
      assert_not_includes fountain_content, "EXT."
    end

    test "should validate time_of_day values" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)

      # Valid time_of_day
      scene = sequence.scenes.build(
        title: "Valid Scene",
        time_of_day: "DAY",
        project: @project,
        act: act,
        position: 1
      )
      assert scene.valid?

      # Invalid time_of_day
      scene_invalid = sequence.scenes.build(
        title: "Invalid Scene",
        time_of_day: "INVALID_TIME",
        project: @project,
        act: act,
        position: 2
      )
      assert_not scene_invalid.valid?
      assert_includes scene_invalid.errors[:time_of_day], "INVALID_TIME no es un momento del día válido"
    end

    test "should allow blank time_of_day" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      scene = sequence.scenes.create!(
        title: "Scene Without Time",
        time_of_day: nil,
        project: @project,
        act: act,
        position: 1
      )

      assert scene.valid?
    end
  end
end
