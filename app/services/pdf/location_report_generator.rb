# app/services/pdf/location_report_generator.rb
module Pdf
  class LocationReportGenerator < BaseReportGenerator
    def initialize(location)
      super()
      @location = location
      @project = location.project
    end

    def generate
      add_header("Ficha de Locación", @project.title)
      add_location_info
      add_scenes_info

      @pdf.render
    end

    private

    def add_location_info
      @pdf.text @location.name, size: 22, style: :bold, color: "1B3C53"
      @pdf.move_down 5

      if @location.location_type.present?
        type_text = @location.location_type == "interior" ? "Interior" : "Exterior"
        @pdf.text type_text, size: 12, color: "6B7280"
      end

      @pdf.move_down 5
      @pdf.text "Locación de #{@project.title}", size: 11, color: "9CA3AF"
      @pdf.move_down 25
      add_divider

      # Descripción
      if @location.description.present?
        add_section_title("Descripción")
        @pdf.text @location.description, size: 10, color: "4B5563", leading: 4, align: :justify
        @pdf.move_down 20
        add_divider
      end
    end

    def add_scenes_info
      scenes = @location.scenes.includes(sequence: :act).order("acts.position, sequences.position, scenes.position")

      add_section_title("Apariciones en Escenas")

      if scenes.any?
        @pdf.text "Esta locación aparece en #{scenes.count} #{'escena'.pluralize(scenes.count)}:",
          size: 11, color: "4B5563"
        @pdf.move_down 15

        scenes.each do |scene|
          add_scene_entry(scene)
        end
      else
        @pdf.text "Esta locación aún no se utiliza en ninguna escena.",
          size: 10, color: "9CA3AF", style: :italic
      end
    end

    def add_scene_entry(scene)
      # Título de la escena
      @pdf.text scene.title, size: 11, style: :bold, color: "374151"
      @pdf.move_down 3

      # Ubicación en la estructura
      structure_text = "#{scene.sequence.act.title} › #{scene.sequence.title}"
      @pdf.text structure_text, size: 9, color: "6B7280"

      # Descripción de la escena si existe
      if scene.description.present?
        @pdf.move_down 3
        @pdf.text scene.description, size: 9, color: "9CA3AF", leading: 3
      end

      @pdf.move_down 12
    end
  end
end
