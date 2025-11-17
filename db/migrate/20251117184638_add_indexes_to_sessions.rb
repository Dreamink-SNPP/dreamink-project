class AddIndexesToSessions < ActiveRecord::Migration[8.1]
  def change
    add_index :sessions, :created_at, comment: "For session analytics and cleanup queries"
    add_index :sessions, :ip_address, comment: "For security auditing and filtering by IP"
  end
end
