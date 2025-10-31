require_relative "../../test_helper"

module Pdf
  class IdeasCollectionReportGeneratorTest < ActiveSupport::TestCase
    setup do
      @user = fixture_to_model(users(:one), User)
      @project = fixture_to_model(projects(:one), Project)
    end

    test "should generate PDF for ideas collection" do
      generator = Pdf::IdeasCollectionReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.is_a?(String)
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle project with no ideas" do
      @project.ideas.destroy_all

      generator = Pdf::IdeasCollectionReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle project with multiple ideas" do
      # Create additional ideas
      @project.ideas.create!(
        title: "Second Idea",
        description: "Another great concept"
      )
      @project.ideas.create!(
        title: "Third Idea",
        description: "Yet another concept",
        tags: "action, drama"
      )

      generator = Pdf::IdeasCollectionReportGenerator.new(@project)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end
  end
end
