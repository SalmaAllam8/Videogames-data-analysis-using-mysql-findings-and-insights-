
SHOW INDEX FROM videogames.new_games;

CREATE INDEX idx_previous_game ON videogames.new_games(previous_game);
CREATE INDEX idx_title ON videogames.new_games(title);


SET SESSION cte_max_recursion_depth = 50;


WITH RECURSIVE franchise_tree AS (
    SELECT
        title,
        genre,
        previous_game,
        estimated_revenue_million_usd,
        1 AS franchise_generation,
        CAST(title AS CHAR(1000)) AS lineage_path
    FROM videogames.new_games
    WHERE title = 'FIFA 2023'

    UNION ALL

    SELECT
        g.title,
        g.genre,
        g.previous_game,
        g.estimated_revenue_million_usd,
        ft.franchise_generation + 1,
        CAST(CONCAT(ft.lineage_path, ' ➡️ ', g.title) AS CHAR(1000))
    FROM videogames.new_games g
    JOIN franchise_tree ft ON g.previous_game = ft.title
    -- cycle guard: stop if this title is already in the path
    WHERE FIND_IN_SET(g.title, REPLACE(ft.lineage_path, ' ➡️ ', ',')) = 0
)

SELECT
    franchise_generation,
    title,
    estimated_revenue_million_usd AS generation_revenue,
    lineage_path
FROM franchise_tree
ORDER BY franchise_generation ASC;






