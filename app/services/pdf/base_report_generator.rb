# app/services/pdf/base_report_generator.rb
require 'prawn'
require 'prawn/table'

module Pdf
  class BaseReportGenerator
    def initialize
      @pdf = Prawn::Document.new(
        page_size: 'A4',
        page_layout: :portrait,
        margin: 40
      )
      setup_fonts
    end

    def generate
      raise NotImplementedError, 'Subclasses must implement #generate'
    end

    private

    def setup_fonts
      @pdf.font_families.update(
        "DejaVu" => {
          normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf").to_s,
          bold: Rails.root.join("app/assets/fonts/DejaVuSans-Bold.ttf").to_s
        }
      )
      @pdf.font "DejaVu"
    rescue => e
      # Fallback to default font if custom fonts are not available
      Rails.logger.warn "Could not load custom fonts: #{e.message}"
    end

    def add_header(title, subtitle = nil)
      @pdf.text title, size: 24, style: :bold, color: '4F46E5'
      @pdf.text subtitle, size: 12, color: '6B7280' if subtitle
      @pdf.move_down 20
      add_divider
    end

    def add_section_title(title, emoji = nil)
      @pdf.move_down 15
      text = emoji ? "#{emoji} #{title}" : title
      @pdf.text text, size: 16, style: :bold, color: '1F2937'
      @pdf.move_down 10
    end

    def add_field(label, value, options = {})
      return if value.blank? && !options[:show_blank]

      @pdf.text label, size: 10, style: :bold, color: '374151'
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

    def add_footer
      @pdf.number_pages "<page> / <total>",
        at: [ @pdf.bounds.right - 50, 0 ],
        align: :right,
        size: 9,
        color: '9CA3AF'

      @pdf.repeat(:all) do
        @pdf.bounding_box([ @pdf.bounds.left, 0 ], width: @pdf.bounds.width) do
          @pdf.move_down 5
          @pdf.text "Generado con Dreamink - #{Time.current.strftime('%d/%m/%Y %H:%M')}",
            size: 8,
            color: '9CA3AF',
            align: :left
        end
      end
    end
  end
end
