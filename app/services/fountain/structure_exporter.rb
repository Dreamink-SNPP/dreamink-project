# frozen_string_literal: true

module Fountain
  class StructureExporter
    attr_reader :project

    def initialize(project)
      @project = project
      @seen_locations = Set.new
    end

    def generate
      output = []

      # Add title page info
      output << "Title: #{project.title}"
      output << "Credit: written by"
      output << "Author: #{project.user&.email || 'Unknown'}"
      output << "Draft date: #{Date.today.strftime('%m/%d/%Y')}"

      # Add genre if available
      if project.genre.present?
        output << "Genre: #{project.genre}"
      end

      # Add character list if available
      characters = project.characters.order(:name)
      if characters.any?
        characters.each do |character|
          output << "Character: #{character.name}"
        end
      end

      output << ""
      output << "==="
      output << ""

      # Reset seen locations for this export
      @seen_locations.clear

      # Load acts with nested sequences, scenes, and locations
      acts = project.acts.includes(sequences: { scenes: :locations }).order(position: :asc)

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
      # Section heading for organization
      output << "### #{scene.title}"
      output << ""

      # Proper Fountain scene heading if locations are available
      scene_heading = build_scene_heading(scene)
      if scene_heading.present?
        output << scene_heading
        output << ""
      end

      # Add location descriptions as notes for first-time appearances
      export_location_notes(scene, output)

      if scene.description.present?
        export_description(scene.description, output)
      end
    end

    def export_location_notes(scene, output)
      return if scene.locations.empty?

      scene.locations.each do |location|
        # Only add note if this is the first time we're seeing this location
        next if @seen_locations.include?(location.id)

        # Mark as seen
        @seen_locations.add(location.id)

        # Add location description as a Fountain note if available
        if location.description.present?
          output << "[[#{location.name}: #{location.description}]]"
          output << ""
        end
      end
    end

    def build_scene_heading(scene)
      return nil if scene.locations.empty?

      # Get INT/EXT from locations
      location_types = scene.locations.map { |l| l.interior? ? "INT" : "EXT" }.uniq
      int_ext = location_types.join("/")

      # Get location names
      location_names = scene.locations.map(&:name).join("/")

      # Build heading parts
      heading_parts = [ int_ext, location_names ].compact.join(". ")

      # Add time of day if available
      if scene.time_of_day.present?
        heading_parts += " - #{scene.time_of_day}"
      end

      heading_parts
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
