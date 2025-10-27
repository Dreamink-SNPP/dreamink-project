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
      remove_from_list

      self.act = new_act
      self.project_id = new_act.project_id

      if new_position
        self.position = new_position
      else
        self.position = new_act.sequences.maximum(:position).to_i + 1
      end

      save!

      scenes.update_all(
        act_id: new_act.id,
        project_id: new_act.project_id
      )

      add_to_list(position)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error moving sequence: #{e.message}"
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
