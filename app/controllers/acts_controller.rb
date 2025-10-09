class ActsController < ApplicationController
  include ProjectAuthorization

  before_action :set_act, only: [ :edit, :update, :destroy ]

  def index
    @acts = @project.acts.ordered
  end

  def new
    @act = @project.acts.build
  end

  def create
    @act = @project.acts.build(act_params)

    respond_to do |format|
      if @act.save
        format.turbo_stream do
          render turbo_stream: [
            # Cerrar el modal
            turbo_stream.update("new_act_modal_content", partial: "acts/success"),
            # Agregar el nuevo acto a la estructura
            turbo_stream.append("acts_container",
                                partial: "structures/act_column",
                                locals: { act: @act, project: @project }
            ),
            # Mostrar mensaje flash
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Acto creado exitosamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Acto creado exitosamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("act_form",
                                                    partial: "acts/form",
                                                    locals: { act: @act }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @act.update(act_params)
        format.turbo_stream do
          render turbo_stream: [
            # Actualizar la columna del acto
            turbo_stream.replace("act_#{@act.id}",
                                 partial: "structures/act_column",
                                 locals: { act: @act, project: @project }
            ),
            # Mostrar mensaje
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Acto actualizado exitosamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Acto actualizado exitosamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("act_form",
                                                    partial: "acts/form",
                                                    locals: { act: @act }
          )
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @act.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # Eliminar la columna del acto
          turbo_stream.remove("act_#{@act.id}"),
          # Mostrar mensaje
          turbo_stream.prepend("flash_messages",
                               partial: "shared/flash_notice",
                               locals: { message: "Acto eliminado exitosamente" }
          )
        ]
      end
      format.html { redirect_to project_structure_path(@project), notice: "Acto eliminado exitosamente" }
    end
  end

  private

  def set_act
    @act = @project.acts.find(params[:id])
  end

  def act_params
    params.require(:act).permit(:title, :description, :position)
  end
end
