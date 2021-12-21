class AddStats < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE SCHEMA IF NOT EXISTS stats;

      CREATE VIEW stats.all_users AS (
        SELECT DISTINCT team_id, from_id AS user_id FROM points
        UNION
        SELECT DISTINCT team_id, to_id   AS user_id FROM points
      );

      CREATE VIEW stats.points_given AS (
        SELECT
          count(*)
        , team_id
        , from_id AS user_id
        FROM points
        GROUP BY 2,3
      );

      CREATE VIEW stats.points_received AS (
        SELECT
        count(*)
        , team_id
        , to_id AS user_id
        FROM points
        GROUP BY 2,3
      );

      CREATE OR REPLACE VIEW stats.points_scores AS (
        WITH _scores AS (
          SELECT
            COALESCE(pg.team_id, pr.team_id) AS team_id
          , COALESCE(pg.user_id, pr.user_id) AS user_id
          , COALESCE(pg.count, 0) AS points_given
          , COALESCE(pr.count, 0) AS points_received
          FROM stats.points_given pg
          FULL OUTER JOIN stats.points_received pr ON pg.user_id = pr.user_id
        )
        SELECT
          _scores.*
        , TRUNC(CASE points_received
                  WHEN 0 THEN NULL
                  ELSE points_given::DECIMAL / points_received
                END
                , 2) AS points_given_ratio
        , TRUNC(CASE points_given
                  WHEN 0 THEN NULL
                  ELSE points_received::DECIMAL / points_given
                END
                , 2) AS points_received_ratio
        FROM _scores
      );

      CREATE OR REPLACE VIEW stats.emoji AS (
        SELECT DISTINCT
          UNNEST(REGEXP_MATCHES(reason, ':[^: ]+:', 'ig'))
        FROM points
        ORDER BY 1
      );

      CREATE OR REPLACE VIEW stats.emoji_occurrences AS (
        SELECT
          points.id
        , UNNEST(REGEXP_MATCHES(reason, ':[^: ]+:', 'ig')) AS emoji
        FROM points
        WHERE created_at >= '2021-01-01'
          AND created_at < '2022-01-01'
      );

      CREATE OR REPLACE VIEW stats.foo_daily AS (
        WITH
          _ptiles AS (
            SELECT
              k
            , percentile_cont(k) within GROUP (ORDER BY pd.value) AS val_cont
            , percentile_disc(k) within GROUP (ORDER BY pd.value) AS val_disc
            FROM
              stats.points_daily AS pd
            , generate_series(0.01, 1, 0.01) as k
            GROUP BY k
            ORDER BY k DESC
          )
        , _joined AS (
          SELECT
            pd.*
          , (_ptiles.k * 100)::INTEGER AS percentile
          FROM stats.points_daily pd
          JOIN _ptiles ON pd.value >= _ptiles.val_cont
        )
        SELECT DISTINCT ON (dates.date)
          dates.date
        , COALESCE(_joined.value, 0) AS value
        , COALESCE(_joined.percentile, 0) AS percentile
        FROM _joined
        FULL OUTER JOIN (
          SELECT generate_series(timestamp '2020-12-31', '2022-01-01', '1 day')::date AS date
        ) dates ON _joined.date = dates.date
        ORDER BY
          dates.date ASC
        , percentile DESC
      );

      CREATE OR REPLACE VIEW stats.emoji_frequency AS (
        SELECT
          UNNEST(REGEXP_MATCHES(reason, ':[^: ]+:', 'ig')) AS emoji
        , COUNT(DISTINCT from_id) AS from_users
        , COUNT(DISTINCT id) AS points
        , COUNT(DISTINCT to_id) AS to_users
        , COUNT(*) AS total_usages
        , ARRAY_AGG(DISTINCT created_at) AS timestamps
        FROM points
        WHERE created_at >= '2021-01-01'
        GROUP BY 1
        ORDER BY 2 DESC, 3 DESC, 5 DESC, 1
      );

      CREATE OR REPLACE VIEW stats.points_daily AS (
        SELECT
          created_at::DATE as date
        , COUNT(*) AS value
        FROM points
        WHERE created_at >= '2021-01-01'
          AND created_At < '2022-01-01'
        GROUP BY 1
        ORDER BY 1
      );

      CREATE OR REPLACE VIEW stats.points_histogram AS (
        SELECT
          DATE_PART('YEAR', created_at) || '-' || LPAD(DATE_PART('MONTH', created_at)::TEXT, 2, '0') AS month
        , COUNT(*) AS value
        , REPEAT('x', COUNT(*)::INTEGER) AS bar
        FROM points
        WHERE created_at >= '2021-01-01'
          AND created_At < '2022-01-01'
        GROUP BY 1
        ORDER BY 1
      );
    SQL
  end

  def down
    execute <<-SQL
      DROP SCHEMA stats CASCADE;
    SQL
  end
end
