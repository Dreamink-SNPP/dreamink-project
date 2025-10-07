class CharactersController < ApplicationController include ProjectAuthorization
  before_action :set_character, only: [:show, :edit, :update, :destroy]

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
end
