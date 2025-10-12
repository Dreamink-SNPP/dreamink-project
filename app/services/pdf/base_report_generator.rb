# app/services/pdf/base_report_generator.rb
require 'prawn'
require 'prawn/table'

module Pdf
  class BaseReportGenerator
    def initialize
      @pdf = Prawn::Document.new(
        page_size: 'A4',
        page_layout: :portrait,
        margin: [ 40, 40, 60, 40 ]
      )
      setup_fonts
      setup_footer
    end

    def generate
      raise NotImplementedError, 'Subclasses must implement #generate'
    end

    private

    def setup_fonts
      # Intentar cargar fuentes DejaVu del sistema Ubuntu
      dejavu_normal = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
      dejavu_bold = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'

      if File.exist?(dejavu_normal) && File.exist?(dejavu_bold)
        @pdf.font_families.update(
          "DejaVu" => {
            normal: dejavu_normal,
            bold: dejavu_bold
          }
        )
        @pdf.font "DejaVu"
        @use_emojis = true
        Rails.logger.info "✓ Fuentes DejaVu cargadas correctamente"
      else
        # Fallback a Liberation fonts
        liberation_normal = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
        liberation_bold = '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf'

        if File.exist?(liberation_normal) && File.exist?(liberation_bold)
          @pdf.font_families.update(
            "Liberation" => {
              normal: liberation_normal,
              bold: liberation_bold
            }
          )
          @pdf.font "Liberation"
          @use_emojis = false
          Rails.logger.warn "⚠ Usando Liberation fonts - emojis deshabilitados"
        else
          # Si no hay fuentes disponibles, deshabilitamos emojis
          @use_emojis = false
          Rails.logger.error "✗ No se encontraron fuentes UTF-8. Emojis deshabilitados."
          Rails.logger.error "Para habilitar emojis, instalá: sudo apt-get install fonts-dejavu"
        end
      end
    rescue StandardError => e
      @use_emojis = false
      Rails.logger.error "Error cargando fuentes: #{e.message}"
    end

    def setup_footer
      # Footer que se repite en todas las páginas
      @pdf.repeat(:all, dynamic: true) do
        @pdf.canvas do
          @pdf.fill_color '9CA3AF'

          # Línea superior del footer
          @pdf.stroke_color 'E5E7EB'
          @pdf.stroke_horizontal_line 0, @pdf.bounds.right, at: 30

          # Texto de generación (izquierda)
          @pdf.draw_text "Generado con Dreamink - #{Time.current.strftime('%d/%m/%Y %H:%M')}",
            at: [ 0, 15 ],
            size: 8

          # Número de página (derecha)
          page_text = "Página #{@pdf.page_number}"
          @pdf.draw_text page_text,
            at: [ @pdf.bounds.right - @pdf.width_of(page_text, size: 9), 15 ],
            size: 9

          # Restaurar color
          @pdf.fill_color '000000'
        end
      end
    end

    def add_header(title, subtitle = nil)
      @pdf.text title, size: 24, style: :bold, color: '4F46E5'
      @pdf.text subtitle, size: 12, color: '6B7280' if subtitle
      @pdf.move_down 20
      add_divider
    end

    def add_section_title(title, emoji = nil)
      @pdf.move_down 15
      # Solo agregar emoji si las fuentes lo soportan
      text = (@use_emojis && emoji) ? "#{emoji} #{title}" : title
      @pdf.text text, size: 16, style: :bold, color: '1F2937'
      @pdf.move_down 10
    end

    def add_field(label, value, options = {})
      return if value.blank? && !options[:show_blank]

      # Remover emojis del label si no hay soporte
      clean_label = @use_emojis ? label : label.gsub(/[ \u{1F300}-\u{1F9FF} ]/, "").strip

      @pdf.text clean_label, size: 10, style: :bold, color: '374151'
      @pdf.move_down 3

      if value.present?
        @pdf.text value.to_s, size: 10, color: '4B5563', leading: 3
      else
        @pdf.text "(No especificado)", size: 10, color: '9CA3AF', style: :italic
      end

      @pdf.move_down 8
    end

    def add_divider
      @pdf.stroke_color 'E5E7EB'
      @pdf.stroke_horizontal_rule
      @pdf.move_down 15
    end
  end
end
