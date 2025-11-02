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

    test "should include character list in title page" do
      @project.characters.create!(name: "John Doe")
      @project.characters.create!(name: "Jane Smith")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "Character: John Doe"
      assert_includes fountain_content, "Character: Jane Smith"
    end

    test "should sort characters alphabetically" do
      @project.characters.create!(name: "Zack")
      @project.characters.create!(name: "Alice")
      @project.characters.create!(name: "Bob")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      # Check that characters appear in alphabetical order
      alice_pos = fountain_content.index("Character: Alice")
      bob_pos = fountain_content.index("Character: Bob")
      zack_pos = fountain_content.index("Character: Zack")

      assert alice_pos < bob_pos
      assert bob_pos < zack_pos
    end

    test "should handle project with no characters" do
      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_not_nil fountain_content
      assert_includes fountain_content, "Title: #{@project.title}"
      # Should still have title page delimiter
      assert_includes fountain_content, "==="
    end

    test "should place character list between author and delimiter" do
      @project.characters.create!(name: "Hero")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      author_pos = fountain_content.index("Author:")
      character_pos = fountain_content.index("Character: Hero")
      delimiter_pos = fountain_content.index("===")

      assert author_pos < character_pos
      assert character_pos < delimiter_pos
    end

    test "should include genre in title page when present" do
      @project.update!(genre: "Science Fiction")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "Genre: Science Fiction"
    end

    test "should not include genre when blank" do
      @project.update!(genre: nil)

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_not_includes fountain_content, "Genre:"
    end

    test "should place genre after draft date and before characters" do
      @project.update!(genre: "Drama")
      @project.characters.create!(name: "Hero")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      draft_date_pos = fountain_content.index("Draft date:")
      genre_pos = fountain_content.index("Genre: Drama")
      character_pos = fountain_content.index("Character: Hero")

      assert draft_date_pos < genre_pos
      assert genre_pos < character_pos
    end

    test "should place genre after draft date when no characters" do
      @project.update!(genre: "Thriller")

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      draft_date_pos = fountain_content.index("Draft date:")
      genre_pos = fountain_content.index("Genre: Thriller")
      delimiter_pos = fountain_content.index("===")

      assert draft_date_pos < genre_pos
      assert genre_pos < delimiter_pos
    end

    test "should add location description as note on first appearance" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(
        name: "Coffee Shop",
        location_type: "interior",
        description: "A cozy neighborhood spot with vintage furniture and exposed brick walls"
      )
      scene = sequence.scenes.create!(
        title: "First Scene",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "[[Coffee Shop: A cozy neighborhood spot with vintage furniture and exposed brick walls]]"
    end

    test "should not add location note on subsequent appearances" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(
        name: "Coffee Shop",
        location_type: "interior",
        description: "A cozy spot"
      )

      # First scene with location
      scene1 = sequence.scenes.create!(
        title: "First Visit",
        description: "First time here",
        project: @project,
        act: act,
        position: 1
      )
      scene1.locations << location

      # Second scene with same location
      scene2 = sequence.scenes.create!(
        title: "Second Visit",
        description: "Back again",
        project: @project,
        act: act,
        position: 2
      )
      scene2.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      # Note should appear only once
      assert_equal 1, fountain_content.scan(/\[\[Coffee Shop:/).count
    end

    test "should add notes for multiple locations on first appearance" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location1 = @project.locations.create!(
        name: "Apartment",
        location_type: "interior",
        description: "A modern loft with high ceilings"
      )
      location2 = @project.locations.create!(
        name: "Street",
        location_type: "exterior",
        description: "Busy downtown street corner"
      )
      scene = sequence.scenes.create!(
        title: "Mixed Scene",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location1
      scene.locations << location2

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_includes fountain_content, "[[Apartment: A modern loft with high ceilings]]"
      assert_includes fountain_content, "[[Street: Busy downtown street corner]]"
    end

    test "should not add note for location without description" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(
        name: "Generic Room",
        location_type: "interior",
        description: nil
      )
      scene = sequence.scenes.create!(
        title: "Scene",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      assert_not_includes fountain_content, "[[Generic Room:"
      assert_not_includes fountain_content, "[["
    end

    test "should place location note after scene heading and before description" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence = act.sequences.create!(title: "Opening", project: @project, position: 1)
      location = @project.locations.create!(
        name: "Library",
        location_type: "interior",
        description: "Old dusty library"
      )
      scene = sequence.scenes.create!(
        title: "Research Scene",
        description: "The protagonist searches for clues",
        time_of_day: "NIGHT",
        project: @project,
        act: act,
        position: 1
      )
      scene.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      scene_heading_pos = fountain_content.index("INT. Library - NIGHT")
      note_pos = fountain_content.index("[[Library: Old dusty library]]")
      description_pos = fountain_content.index("= The protagonist searches for clues")

      assert scene_heading_pos < note_pos
      assert note_pos < description_pos
    end

    test "should handle location appearing in different scenes across sequences" do
      act = @project.acts.create!(title: "Act One", position: 1)
      sequence1 = act.sequences.create!(title: "Sequence A", project: @project, position: 1)
      sequence2 = act.sequences.create!(title: "Sequence B", project: @project, position: 2)

      location = @project.locations.create!(
        name: "Home",
        location_type: "interior",
        description: "Cozy home"
      )

      # First appearance in sequence 1
      scene1 = sequence1.scenes.create!(
        title: "Morning at Home",
        project: @project,
        act: act,
        position: 1
      )
      scene1.locations << location

      # Second appearance in sequence 2
      scene2 = sequence2.scenes.create!(
        title: "Evening at Home",
        project: @project,
        act: act,
        position: 1
      )
      scene2.locations << location

      exporter = Fountain::StructureExporter.new(@project)
      fountain_content = exporter.generate

      # Note should appear only once (in first sequence)
      assert_equal 1, fountain_content.scan(/\[\[Home:/).count

      # Should appear in sequence A section
      seq_a_pos = fountain_content.index("## Sequence A")
      note_pos = fountain_content.index("[[Home: Cozy home]]")
      seq_b_pos = fountain_content.index("## Sequence B")

      assert seq_a_pos < note_pos
      assert note_pos < seq_b_pos
    end
  end
end
