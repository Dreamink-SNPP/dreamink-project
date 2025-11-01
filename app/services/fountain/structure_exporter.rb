# frozen_string_literal: true

module Fountain
  class StructureExporter
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def generate
      output = []

      # Add title page info
      output << "Title: #{project.title}"
      output << "Credit: written by"
      output << "Author: #{project.user&.email || 'Unknown'}"
      output << "Draft date: #{Date.today.strftime('%m/%d/%Y')}"
      output << ""
      output << "==="
      output << ""

      # Load acts with nested sequences and scenes
      acts = project.acts.includes(sequences: :scenes).order(position: :asc)

      acts.each do |act|
        export_act(act, output)
      end

      output.join("\n")
    end

    private

    def export_act(act, output)
      output << "# #{act.title}"
      output << ""

      if act.description.present?
        export_description(act.description, output)
      end

      act.sequences.each do |sequence|
        export_sequence(sequence, output)
      end

      output << ""
    end

    def export_sequence(sequence, output)
      output << "## #{sequence.title}"
      output << ""

      if sequence.description.present?
        export_description(sequence.description, output)
      end

      sequence.scenes.each do |scene|
        export_scene(scene, output)
      end

      output << ""
    end

    def export_scene(scene, output)
      output << "### #{scene.title}"
      output << ""

      if scene.description.present?
        export_description(scene.description, output)
      end
    end

    def export_description(description, output)
      # Hybrid approach: single-line descriptions use synopsis (=),
      # multi-line descriptions use regular paragraphs
      lines = description.strip.lines.map(&:strip).reject(&:empty?)

      if lines.size == 1
        # Single line - use Fountain synopsis syntax
        output << "= #{lines.first}"
        output << ""
      else
        # Multi-line - use regular paragraph format
        lines.each do |line|
          output << line
        end
        output << ""
      end
    end
  end
end
