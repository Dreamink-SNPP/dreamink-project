module Pdf
  class CharactersCollectionReportGenerator < BaseReportGenerator
    def initialize(project)
      super()
      @project = project
      @characters = project.characters.order(:name)
    end

    def generate
      add_header("Reporte de Personajes", @project.title)
      add_summary
      add_characters_details
      add_footer

      @pdf.render
    end

    private

    def add_summary
      @pdf.text "Resumen", size: 18, style: :bold, color: '1F2937'
      @pdf.move_down 10

      @pdf.text "Total de personajes: #{@characters.count}", size: 12, color: '4B5563'
      @pdf.text "Fecha de generación: #{Time.current.strftime('%d/%m/%Y %H:%M')}",
        size: 10, color: '6B7280'

      @pdf.move_down 20
      add_divider
    end

    def add_characters_details
      @characters.each_with_index do |character, index|
        @pdf.start_new_page unless index.zero?
        add_character_section(character)
      end
    end

    def add_character_section(character)
      # Encabezado del personaje
      @pdf.text character.name, size: 20, style: :bold, color: '4F46E5'
      @pdf.move_down 15
      add_divider

      # Características internas
      if character.internal_trait
        add_section_title("Características Internas", "🧠")
        add_internal_trait_summary(character.internal_trait)
        add_divider
      end

      # Características externas
      if character.external_trait
        add_section_title("Características Externas", "👁️")
        add_external_trait_summary(character.external_trait)
      end
    end

    def add_internal_trait_summary(trait)
      add_field("🎯 Motivación Principal", trait.main_motivation)
      add_field("💪 Habilidades", trait.skills)
      add_field("🧠 Identidad", trait.identity)
      add_field("🙏 Religión", trait.religion)
      add_field("✨ Espiritualidad", trait.spirituality)
      add_field("💭 Creencias", trait.beliefs)
      add_field("⚖️ Ética", trait.ethics)
      add_field("💎 Valores y Prioridades", trait.values_priorities)
      add_field("🚬 Vicios", trait.vices)
      add_field("🎮 Pasatiempos", trait.hobbies)
    end

    def add_external_trait_summary(trait)
      add_field("👁️ Apariencia General", trait.general_appearance)
      add_field("💼 Profesión", trait.profession)
      add_field("🎓 Educación", trait.education)
      add_field("💰 Situación Económica", trait.economic_situation)
      add_field("🏠 Tipo de Residencia", trait.residence_type)
      add_field("📍 Locación Habitual", trait.usual_location)
      add_field("👨‍👩‍👧‍👦 Estructura Familiar", trait.family_structure)
    end
  end
end
