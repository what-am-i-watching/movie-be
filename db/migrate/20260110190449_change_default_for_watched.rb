class ChangeDefaultForWatched < ActiveRecord::Migration[8.1]
  def change
    change_column_default :user_movies, :watched, from: nil, to: false
  end
end
