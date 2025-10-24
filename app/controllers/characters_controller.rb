class CharactersController < ApplicationController
  include ProjectAuthorization

  before_action :set_character, only: [ :show, :edit, :update, :destroy ]

  def index
    @characters = @project.characters.order(:name)
  end

  def show
  end

  def new
    @character = @project.characters.build
    @character.build_internal_trait
    @character.build_external_trait
  end

  def create
    @character = @project.characters.build(character_params)

    if @character.save
      redirect_to project_character_path(@project, @character), notice: "Personaje creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @character.update(character_params)
      redirect_to project_character_path(@project, @character), notice: "Personaje actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @character.destroy
    redirect_to project_characters_path(@project), notice: "Personaje eliminado exitosamente"
  end

  # Generar PDF de un personaje individual
  def report
    @character = @project.characters.find(params[:id])

    pdf_generator = Pdf::CharacterReportGenerator.new(@character)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
      filename: "personaje_#{@character.name.parameterize}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  # Generar PDF de todos los personajes
  def collection_report
    pdf_generator = Pdf::CharactersCollectionReportGenerator.new(@project)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
      filename: "personajes_#{@project.title.parameterize}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  private

  def set_character
    @character = @project.characters.find(params[:id])
  end

  def character_params
    params.require(:character).permit(
      :name,
      internal_trait_attributes: [
        :id, :skills, :religion, :spirituality, :identity, :beliefs,
        :mental_programs, :ethics, :sexuality, :main_motivation,
        :friendship_relations, :conversation_focus, :self_awareness_level,
        :values_priorities, :time_management, :artistic_inclinations,
        :heroes_models, :political_ideas, :authority_relationship,
        :vices, :temporal_location, :food_preferences, :habits,
        :peculiarities, :hobbies, :charitable_activities
      ],
      external_trait_attributes: [
        :id, :general_appearance, :detailed_appearance, :medical_history,
        :family_structure, :education, :profession, :legal_situation,
        :economic_situation, :important_possessions, :residence_type,
        :usual_location, :pets
      ]
    )
  end
end
