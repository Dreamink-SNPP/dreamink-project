# app/services/pdf/character_report_generator.rb
module Pdf
  class CharacterReportGenerator < BaseReportGenerator
    def initialize(character)
      super()
      @character = character
      @project = character.project
    end

    def generate
      add_header("Ficha de Personaje", @project.title)
      add_character_basic_info
      add_internal_traits
      add_external_traits
      add_footer

      @pdf.render
    end

    private

    def add_character_basic_info
      @pdf.text @character.name, size: 20, style: :bold, color: '4F46E5'
      @pdf.move_down 5
      @pdf.text "Personaje de #{@project.title}", size: 11, color: '6B7280'
      @pdf.move_down 20
      add_divider
    end

    def add_internal_traits
      return unless @character.internal_trait

      trait = @character.internal_trait

      add_section_title("Características Internas", "🧠")

      # Motivación y aspectos principales
      add_field("🎯 Motivación Principal", trait.main_motivation)
      add_field("💪 Habilidades", trait.skills)
      add_field("🧠 Identidad", trait.identity)
      add_field("💫 Sexualidad", trait.sexuality)

      add_divider

      # Creencias y valores
      add_field("🙏 Religión", trait.religion)
      add_field("✨ Espiritualidad", trait.spirituality)
      add_field("💭 Creencias", trait.beliefs)
      add_field("⚖️ Ética", trait.ethics)
      add_field("💎 Valores y Prioridades", trait.values_priorities)

      add_divider

      # Aspectos psicológicos
      add_field("🧩 Programas Mentales", trait.mental_programs)
      add_field("🎭 Nivel de Autoconciencia", trait.self_awareness_level)
      add_field("👥 Relaciones de Amistad", trait.friendship_relations)
      add_field("💬 Focos de Conversación", trait.conversation_focus)
      add_field("👮 Relación con Autoridad", trait.authority_relationship)

      add_divider

      # Tiempo y actividades
      add_field("⏰ Administración del Tiempo", trait.time_management)
      add_field("📅 Ubicación Temporal", trait.temporal_location)
      add_field("🎨 Inclinaciones Artísticas", trait.artistic_inclinations)
      add_field("🎮 Pasatiempos", trait.hobbies)
      add_field("💝 Actividades Caritativas", trait.charitable_activities)

      add_divider

      # Preferencias y hábitos
      add_field("🍽️ Preferencias Alimenticias", trait.food_preferences)
      add_field("🔄 Hábitos", trait.habits)
      add_field("🎪 Peculiaridades", trait.peculiarities)
      add_field("🚬 Vicios", trait.vices)

      add_divider

      # Referencias e influencias
      add_field("🌟 Héroes y Modelos", trait.heroes_models)
      add_field("🏛️ Ideas Políticas", trait.political_ideas)
    end

    def add_external_traits
      return unless @character.external_trait

      trait = @character.external_trait

      @pdf.start_new_page
      add_section_title("Características Externas", "👁️")

      # Apariencia
      add_field("👁️ Apariencia General", trait.general_appearance)
      add_field("🎭 Apariencia Detallada", trait.detailed_appearance)

      add_divider

      # Situación personal
      add_field("🏥 Historial Médico", trait.medical_history)
      add_field("👨‍👩‍👧‍👦 Estructura Familiar", trait.family_structure)
      add_field("🐾 Mascotas", trait.pets)

      add_divider

      # Educación y profesión
      add_field("🎓 Educación", trait.education)
      add_field("💼 Profesión", trait.profession)

      add_divider

      # Situación legal y económica
      add_field("⚖️ Situación Legal", trait.legal_situation)
      add_field("💰 Situación Económica", trait.economic_situation)
      add_field("💎 Posesiones Importantes", trait.important_possessions)

      add_divider

      # Residencia y ubicación
      add_field("🏠 Tipo de Residencia", trait.residence_type)
      add_field("📍 Locación Habitual", trait.usual_location)
    end
  end
end
