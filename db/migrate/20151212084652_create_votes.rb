class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t| 
      t.string :vote
      t.datetime :vote_date

      t.references :user, index: true
      t.timestamps
    end
  end
end
