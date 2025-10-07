include UserScoped

class Character < ApplicationRecord
  belongs_to :project

  has_one :internal_trait, class_name: 'CharacterInternalTrait', dependent: :destroy
  has_one :external_trait, class_name: 'CharacterExternalTrait', dependent: :destroy

  accepts_nested_attributes_for :internal_trait, :external_trait

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :project_id, message: "ya existe en este proyecto" }

  # Callbacks:
  after_create :create_default_traits

  private

  def create_default_traits
    create_internal_trait! unless internal_trait
    create_external_trait! unless external_trait
  end
end
