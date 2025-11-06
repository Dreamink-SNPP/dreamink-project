include UserScoped

class Sequence < ApplicationRecord
  belongs_to :act
  belongs_to :project

  has_many :scenes, -> { order(position: :asc) }, dependent: :destroy

  acts_as_list scope: :act

  validates :title, presence: true, length: { maximum: 100 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_position, on: :create
  before_validation :sync_project_reference

  scope :ordered, -> { order(position: :asc) }

  def move_to_act(new_act, new_position: nil)
    return false if new_act.nil?
    return true if act_id == new_act.id

    ActiveRecord::Base.transaction do
      old_act_id = self.act_id
      old_position = self.position

      target_position = new_position || (new_act.sequences.maximum(:position).to_i + 1)

      # Move this sequence to a temporary position first to avoid conflicts
      temp_position = 999999
      update_columns(
        act_id: new_act.id,
        project_id: new_act.project_id,
        position: temp_position
      )

      # Make space in target act using temp negative positions to avoid constraint violations
      if target_position <= new_act.sequences.where.not(id: self.id).maximum(:position).to_i
        sequences_to_shift_down = Sequence.where(act_id: new_act.id)
                                          .where.not(id: self.id)
                                          .where("position >= ?", target_position)
                                          .order(:position)

        # First shift to temporary negative positions
        sequences_to_shift_down.each_with_index do |seq, index|
          seq.update_columns(position: -(target_position + index + 1000))
        end

        # Then shift to final positions (shifted up by 1)
        sequences_to_shift_down.each_with_index do |seq, index|
          seq.update_columns(position: target_position + index + 1)
        end
      end

      # Close gap in source act using temp negative positions
      # This avoids unique constraint violations during the shift
      sequences_to_shift_up = Sequence.where(act_id: old_act_id)
                                      .where("position > ?", old_position)
                                      .order(:position)

      sequences_to_shift_up.each_with_index do |seq, index|
        seq.update_columns(position: -(old_position + index + 1000))
      end

      sequences_to_shift_up.each_with_index do |seq, index|
        seq.update_columns(position: old_position + index)
      end

      # Finally, place this sequence in its target position
      update_columns(position: target_position)

      # Move associated scenes to the new act and project
      scenes.update_all(
        act_id: new_act.id,
        project_id: new_act.project_id
      )

      reload
    end

    true
  rescue => e
    Rails.logger.error "Error moving sequence: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  private

  def set_position
    self.position ||= act.sequences.maximum(:position).to_i + 1
  end

  def sync_project_reference
    self.project_id = act.project_id if act
  end
end
