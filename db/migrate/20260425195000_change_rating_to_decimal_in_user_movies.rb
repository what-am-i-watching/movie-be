class ChangeRatingToDecimalInUserMovies < ActiveRecord::Migration[8.1]
  CHECK_CONSTRAINT_NAME = "user_movies_rating_half_step_range_check"

  def up
    change_column :user_movies, :rating, :decimal, precision: 2, scale: 1

    add_check_constraint :user_movies,
      "rating IS NULL OR (rating >= 0 AND rating <= 5 AND mod(rating * 2, 1) = 0)",
      name: CHECK_CONSTRAINT_NAME
  end

  def down
    remove_check_constraint :user_movies, name: CHECK_CONSTRAINT_NAME
    change_column :user_movies, :rating, :integer, using: "ROUND(rating)"
  end
end
