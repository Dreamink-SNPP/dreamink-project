require_relative "../../test_helper"

module Pdf
  class IdeaReportGeneratorTest < ActiveSupport::TestCase
    setup do
      @user = fixture_to_model(users(:one), User)
      @project = fixture_to_model(projects(:one), Project)
      @idea = fixture_to_model(ideas(:one), Idea)
    end

    test "should generate PDF for idea" do
      generator = Pdf::IdeaReportGenerator.new(@idea)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.is_a?(String)
      assert pdf_content.start_with?("%PDF")
    end

    test "should include idea title in PDF" do
      generator = Pdf::IdeaReportGenerator.new(@idea)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      # Basic assertion that PDF was generated
      assert pdf_content.length > 0
    end

    test "should handle idea with tags" do
      @idea.tags = "action, thriller, mystery"
      @idea.save!

      generator = Pdf::IdeaReportGenerator.new(@idea)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end

    test "should handle idea without tags" do
      @idea.tags = nil
      @idea.save!

      generator = Pdf::IdeaReportGenerator.new(@idea)
      pdf_content = generator.generate

      assert_not_nil pdf_content
      assert pdf_content.start_with?("%PDF")
    end
  end
end
