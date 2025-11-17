class AddExpiresAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :expires_at, :datetime
    add_index :sessions, :expires_at, comment: "For efficient session cleanup queries"
  end
end
