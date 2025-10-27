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
      remove_from_list

      self.sequence = new_sequence
      self.act_id = new_sequence.act_id
      self.project_id = new_sequence.act.project_id

      if new_position
        self.position = new_position
      else
        self.position = new_sequence.scenes.maximum(:position).to_i + 1
      end

      save!

      insert_at(position) if position
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error moving scene: #{e.message}"
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
