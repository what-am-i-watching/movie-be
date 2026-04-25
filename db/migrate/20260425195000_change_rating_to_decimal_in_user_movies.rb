class ChangeRatingToDecimalInUserMovies < ActiveRecord::Migration[8.1]
  CHECK_CONSTRAINT_NAME = "user_movies_rating_half_step_range_check"

  def up
    change_column :user_movies, :rating, :decimal, precision: 2, scale: 1

    # Normalize pre-existing values so legacy data does not violate the new constraint.
    # - Clamps values to 0..5
    # - Rounds to nearest 0.5 increment
    execute <<~SQL
      UPDATE user_movies
      SET rating = LEAST(5.0, GREATEST(0.0, ROUND(rating * 2) / 2.0))
      WHERE rating IS NOT NULL
        AND (
          rating < 0
          OR rating > 5
          OR mod(rating * 2, 1) <> 0
        )
    SQL

    add_check_constraint :user_movies,
      "rating IS NULL OR (rating >= 0 AND rating <= 5 AND mod(rating * 2, 1) = 0)",
      name: CHECK_CONSTRAINT_NAME
  end

  def down
    remove_check_constraint :user_movies, name: CHECK_CONSTRAINT_NAME
    change_column :user_movies, :rating, :integer, using: "ROUND(rating)"
  end
end
