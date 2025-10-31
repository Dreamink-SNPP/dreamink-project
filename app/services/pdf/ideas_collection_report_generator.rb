module Pdf
  class IdeasCollectionReportGenerator < BaseReportGenerator
    def initialize(project)
      super()
      @project = project
      @ideas = project.ideas.order(:created_at)
    end

    def generate
      add_header("Reporte de Ideas", @project.title)
      add_summary
      add_ideas_details

      @pdf.render
    end

    private

    def add_summary
      @pdf.text "Resumen del Proyecto", size: 18, style: :bold, color: "1F2937"
      @pdf.move_down 10

      @pdf.text "Total de ideas: #{@ideas.count}", size: 12, color: "4B5563"
      @pdf.text "Fecha de generación: #{Time.current.strftime('%d/%m/%Y %H:%M')}",
        size: 10, color: "6B7280"

      @pdf.move_down 20
      add_divider
    end

    def add_ideas_details
      @ideas.each_with_index do |idea, index|
        @pdf.start_new_page unless index.zero?
        add_idea_section(idea)
      end
    end

    def add_idea_section(idea)
      # Encabezado de la idea
      @pdf.text idea.title, size: 22, style: :bold, color: "4F46E5"
      @pdf.move_down 15
      add_divider

      # Detalles
      add_section_title("Detalles")
      add_field("Descripción", idea.description)

      # Tags
      if idea.tags.present?
        tags_text = idea.tag_list.join(", ")
        add_field("Etiquetas", tags_text)
      else
        add_field("Etiquetas", nil)
      end

      add_light_divider

      # Metadatos
      add_section_title("Información de Creación")
      add_field("Fecha de Creación", idea.created_at.strftime("%d/%m/%Y %H:%M"))
      add_field("Última Actualización", idea.updated_at.strftime("%d/%m/%Y %H:%M"))
    end
  end
end
