class ChangeReleaseYearToReleaseDateInMovies < ActiveRecord::Migration[8.1]
  def up
    # Add release_date column
    add_column :movies, :release_date, :date

    # Backfill release_date from release_year
    # Convert year to January 1st of that year
    execute <<-SQL
      UPDATE movies
      SET release_date = CASE
        WHEN release_year IS NOT NULL THEN
          DATE(release_year || '-01-01')
        ELSE NULL
      END
    SQL

    # Remove release_year column
    remove_column :movies, :release_year
  end

  def down
    # Add release_year column back
    add_column :movies, :release_year, :integer

    # Backfill release_year from release_date (extract year)
    execute <<-SQL
      UPDATE movies
      SET release_year = CASE
        WHEN release_date IS NOT NULL THEN
          EXTRACT(YEAR FROM release_date)::integer
        ELSE NULL
      END
    SQL

    # Remove release_date column
    remove_column :movies, :release_date
  end
end
