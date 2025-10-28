include UserScoped

class Scene < ApplicationRecord
  belongs_to :sequence
  belongs_to :act
  belongs_to :project

  has_many :scene_locations, dependent: :destroy
  has_many :locations, through: :scene_locations

  acts_as_list scope: :sequence

  validates :title, presence: true, length: { maximum: 200 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, allow_blank: true }

  before_validation :set_position, on: :create
  before_validation :set_default_color, on: :create
  before_validation :sync_references

  scope :ordered, -> { order(position: :asc) }
  scope :by_color, ->(color) { where(color: color) }

  def move_to_sequence(new_sequence, new_position: nil)
    return false if new_sequence.nil?
    return true if sequence_id == new_sequence.id

    ActiveRecord::Base.transaction do
      old_sequence_id = self.sequence_id
      old_position = self.position

      target_position = new_position || (new_sequence.scenes.maximum(:position).to_i + 1)

      if target_position <= new_sequence.scenes.maximum(:position).to_i
        Scene.where(sequence_id: new_sequence.id)
             .where("position >= ?", target_position)
             .update_all("position = position + 1")
      end

      temp_position = 999999
      update_columns(
        sequence_id: new_sequence.id,
        act_id: new_sequence.act_id,
        project_id: new_sequence.act.project_id,
        position: temp_position
      )

      # Close gap in source sequence using temp negative positions
      # This avoids unique constraint violations during the shift
      scenes_to_shift = Scene.where(sequence_id: old_sequence_id)
                             .where("position > ?", old_position)
                             .order(:position)

      scenes_to_shift.each_with_index do |sc, index|
        sc.update_columns(position: -(old_position + index + 1000))
      end

      scenes_to_shift.each_with_index do |sc, index|
        sc.update_columns(position: old_position + index)
      end

      update_columns(position: target_position)

      reload
    end

    true
  rescue => e
    Rails.logger.error "Error moving scene: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  private

  def set_position
    self.position ||= sequence.scenes.maximum(:position).to_i + 1
  end

  def set_default_color
    self.color ||= "#FFFFFF"
  end

  def sync_references
    if sequence
      self.act_id = sequence.act_id
      self.project_id = sequence.act.project_id
    end
  end
end
