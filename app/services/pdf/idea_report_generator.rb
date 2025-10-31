module Pdf
  class IdeaReportGenerator < BaseReportGenerator
    def initialize(idea)
      super()
      @idea = idea
      @project = idea.project
    end

    def generate
      add_header("Ficha de Idea", @project.title)
      add_idea_basic_info
      add_idea_details

      @pdf.render
    end

    private

    def add_idea_basic_info
      @pdf.text @idea.title, size: 22, style: :bold, color: "4F46E5"
      @pdf.move_down 5
      @pdf.text "Idea de #{@project.title}", size: 11, color: "6B7280"
      @pdf.move_down 25
      add_divider
    end

    def add_idea_details
      add_section_title("Detalles de la Idea")

      # Descripción
      add_field("Descripción", @idea.description)

      # Tags
      if @idea.tags.present?
        tags_text = @idea.tag_list.join(", ")
        add_field("Etiquetas", tags_text)
      else
        add_field("Etiquetas", nil)
      end

      add_light_divider

      # Metadatos
      add_subsection_title("Información de Creación")
      add_field("Fecha de Creación", @idea.created_at.strftime("%d/%m/%Y %H:%M"))
      add_field("Última Actualización", @idea.updated_at.strftime("%d/%m/%Y %H:%M"))
    end
  end
end
