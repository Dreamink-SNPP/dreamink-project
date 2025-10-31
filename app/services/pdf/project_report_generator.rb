module Pdf
  class ProjectReportGenerator < BaseReportGenerator
    def initialize(project)
      super()
      @project = project
    end

    def generate
      add_header("Tratamiento", @project.title)
      add_basic_info
      add_premise_and_concept
      add_synopsis
      add_world_and_themes

      @pdf.render
    end

    private

    def add_basic_info
      # Género y Tono
      if @project.genre.present? || @project.tone.present?
        add_section_title("Información Básica")
        add_field("Género", @project.genre) if @project.genre.present?
        add_field("Tono", @project.tone) if @project.tone.present?
        add_light_divider
      end
    end

    def add_premise_and_concept
      add_section_title("Premisa y Concepto")

      # Logline
      if @project.logline.present?
        add_subsection_title("Logline")
        @pdf.text @project.logline, size: 11, color: "374151", leading: 4
        @pdf.move_down 15
      end

      # Idea
      add_field("Idea", @project.idea)

      # Storyline
      add_field("Storyline", @project.storyline)

      # Motor de la Historia
      add_field("Motor de la Historia", @project.story_engine)

      add_light_divider
    end

    def add_synopsis
      add_section_title("Sinopsis")

      # Sinopsis Corta
      if @project.short_synopsis.present?
        add_subsection_title("Sinopsis Corta")
        @pdf.text @project.short_synopsis, size: 10, color: "4B5563", leading: 4
        @pdf.move_down 15
      end

      # Sinopsis Larga
      if @project.long_synopsis.present?
        add_subsection_title("Sinopsis Larga")
        @pdf.text @project.long_synopsis, size: 10, color: "4B5563", leading: 4
        @pdf.move_down 15
      end

      add_light_divider if @project.short_synopsis.present? || @project.long_synopsis.present?
    end

    def add_world_and_themes
      add_section_title("Mundo y Temas")

      # Mundo
      if @project.world.present?
        add_subsection_title("Mundo / Universo Narrativo")
        @pdf.text @project.world, size: 10, color: "4B5563", leading: 4
        @pdf.move_down 15
      end

      # Temas
      add_field("Temas", @project.themes)

      # Resumen de Personajes
      if @project.characters_summary.present?
        add_subsection_title("Resumen de Personajes")
        @pdf.text @project.characters_summary, size: 10, color: "4B5563", leading: 4
        @pdf.move_down 15
      end
    end
  end
end
