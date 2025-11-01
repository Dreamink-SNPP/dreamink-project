class ActsController < ApplicationController
  include ProjectAuthorization

  before_action :set_act, only: [ :edit, :edit_modal, :update, :destroy, :move_left, :move_right ]

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
            # Cerrar el modal mostrando éxito
            turbo_stream.update("new_act_modal_content",
                                partial: "acts/success"
            ),
            # Agregar el nuevo acto a la estructura
            turbo_stream.append("acts_container",
                                partial: "structures/act_column",
                                locals: { act: @act, project: @project }
            ),
            # Actualizar estadísticas
            turbo_stream.update("statistics_counters",
                                partial: "structures/statistics",
                                locals: {
                                  acts_count: @project.acts.count,
                                  sequences_count: @project.sequences.count,
                                  scenes_count: @project.scenes.count
                                }
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

  def edit_modal
    render layout: false
  end

  def update
    respond_to do |format|
      if @act.update(act_params)
        format.turbo_stream do
          render turbo_stream: [
            # Cerrar el modal mostrando éxito
            turbo_stream.update("edit_act_modal_content",
                                partial: "acts/success_edit"
            ),
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
          # Actualizar estadísticas
          turbo_stream.update("statistics_counters",
                              partial: "structures/statistics",
                              locals: {
                                acts_count: @project.acts.count,
                                sequences_count: @project.sequences.count,
                                scenes_count: @project.scenes.count
                              }
          ),
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

    # Mover acto a la izquierda (decrementar posición)
    def move_left
      target_act = @project.acts.find_by(position: @act.position - 1)

      respond_to do |format|
        if target_act
          swap_positions(@act, target_act)
          format.turbo_stream do
            render turbo_stream: [
              # Reemplazar todo el contenedor de actos para reflejar el nuevo orden
              turbo_stream.update("acts_container",
                                  partial: "structures/acts_list",
                                  locals: { acts: @project.acts.ordered, project: @project }
              ),
              # Mensaje flash
              turbo_stream.prepend("flash_messages",
                                   partial: "shared/flash_notice",
                                   locals: { message: "Acto movido correctamente" }
              )
            ]
          end
          format.html { redirect_to project_structure_path(@project), notice: "Acto movido correctamente" }
        else
          format.turbo_stream do
            render turbo_stream: turbo_stream.prepend("flash_messages",
                                                      partial: "shared/flash_alert",
                                                      locals: { message: "El acto ya está en la primera posición" }
            )
          end
          format.html { redirect_to project_structure_path(@project), alert: "El acto ya está en la primera posición" }
        end
      end
    end

    # Mover acto a la derecha (incrementar posición)
    def move_right
      target_act = @project.acts.find_by(position: @act.position + 1)

      respond_to do |format|
        if target_act
          swap_positions(@act, target_act)
          format.turbo_stream do
            render turbo_stream: [
              # Reemplazar todo el contenedor de actos para reflejar el nuevo orden
              turbo_stream.update("acts_container",
                                  partial: "structures/acts_list",
                                  locals: { acts: @project.acts.ordered, project: @project }
              ),
              # Mensaje flash
              turbo_stream.prepend("flash_messages",
                                   partial: "shared/flash_notice",
                                   locals: { message: "Acto movido correctamente" }
              )
            ]
          end
          format.html { redirect_to project_structure_path(@project), notice: "Acto movido correctamente" }
        else
          format.turbo_stream do
            render turbo_stream: turbo_stream.prepend("flash_messages",
                                                      partial: "shared/flash_alert",
                                                      locals: { message: "El acto ya está en la última posición" }
            )
          end
          format.html { redirect_to project_structure_path(@project), alert: "El acto ya está en la última posición" }
        end
      end
    end

  private

  def set_act
    @act = @project.acts.find(params[:id])
  end

  def act_params
    params.require(:act).permit(:title, :description, :position)
  end

    # Intercambiar posiciones de dos actos evitando el unique constraint
    def swap_positions(act1, act2)
      # Guardar posiciones originales
      pos1 = act1.position
      pos2 = act2.position

      ActiveRecord::Base.transaction do
        # Paso 1: Mover a posiciones temporales negativas
        act1.update_column(:position, -1000)
        act2.update_column(:position, -1001)

        # Paso 2: Asignar las posiciones intercambiadas
        act1.update_column(:position, pos2)
        act2.update_column(:position, pos1)
      end

      Rails.logger.info "Swapped acts #{act1.id} and #{act2.id}"
    end
end
