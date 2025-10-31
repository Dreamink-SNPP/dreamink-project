require_relative "../../test_helper"

module Pdf
  class ProjectReportGeneratorTest < ActiveSupport::TestCase
    setup do
      @user = fixture_to_model(users(:one), User)
      @project = fixture_to_model(projects(:one), Project)
    end

    test "should generate PDF for project" do
      generator = Pdf::ProjectReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.is_a?(String)
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle project with all fields" do
      @project.update!(
        genre: "Drama",
        tone: "Dark and mysterious",
        idea: "A compelling story",
        logline: "A short logline",
        storyline: "The complete storyline",
        story_engine: "The main conflict",
        short_synopsis: "Brief synopsis",
        long_synopsis: "Detailed synopsis",
        world: "The narrative universe",
        themes: "Justice, redemption",
        characters_summary: "Main characters description"
      )

      generator = Pdf::ProjectReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle project with minimal fields" do
      @project.update!(
        genre: nil,
        tone: nil,
        idea: nil,
        logline: nil,
        storyline: nil,
        story_engine: nil,
        short_synopsis: nil,
        long_synopsis: nil,
        world: nil,
        themes: nil,
        characters_summary: nil
      )

      generator = Pdf::ProjectReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle project with only logline" do
      @project.update!(
        logline: "A detective must solve a case before time runs out",
        idea: nil,
        storyline: nil
      )

      generator = Pdf::ProjectReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end
  end
end
