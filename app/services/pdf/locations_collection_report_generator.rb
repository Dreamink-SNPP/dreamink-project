module Pdf
  class LocationsCollectionReportGenerator < BaseReportGenerator
    def initialize(project)
      super()
      @project = project
      @locations = project.locations.order(:name)
    end

    def generate
      add_header("Reporte de Locaciones", @project.title)
      add_summary
      add_locations_details

      @pdf.render
    end

    private

    def add_summary
      @pdf.text "Resumen del Proyecto", size: 18, style: :bold, color: '1F2937'
      @pdf.move_down 10

      interiors_count = @locations.interiors.count
      exteriors_count = @locations.exteriors.count

      @pdf.text "Total de locaciones: #{@locations.count}", size: 12, color: '4B5563'
      @pdf.text "Interiores: #{interiors_count} | Exteriores: #{exteriors_count}",
        size: 11, color: '6B7280'
      @pdf.text "Fecha de generación: #{Time.current.strftime('%d/%m/%Y %H:%M')}",
        size: 10, color: '9CA3AF'

      @pdf.move_down 20
      add_divider
    end

    def add_locations_details
      @locations.each_with_index do |location, index|
        @pdf.start_new_page unless index.zero?
        add_location_section(location)
      end
    end

    def add_location_section(location)
      # Encabezado de la locación
      @pdf.text location.name, size: 22, style: :bold, color: '4F46E5'
      @pdf.move_down 5

      if location.location_type.present?
        type_text = location.interior? ? 'Interior' : 'Exterior'
        @pdf.text type_text, size: 12, color: '6B7280'
        @pdf.move_down 5
      end

      # Contador de escenas
      scenes_count = location.scenes.count
      @pdf.text "Aparece en #{scenes_count} #{'escena'.pluralize(scenes_count)}",
        size: 11, color: '9CA3AF'

      @pdf.move_down 20
      add_divider

      # Descripción
      if location.description.present?
        add_section_title("Descripción")
        @pdf.text location.description, size: 10, color: '4B5563', leading: 4, align: :justify
      else
        @pdf.text "Sin descripción", size: 10, color: '9CA3AF', style: :italic
      end
    end
  end
end
