/*
which genres are oversaturated and which ones have a high financial ceiling but low competition. */

select genre , count(title) as number_of_games , max(estimated_revenue_million_usd) as Maximum_revenue 

from games

group by genre 
having  max(estimated_revenue_million_usd) > (
    SELECT AVG(estimated_revenue_million_usd) FROM games
)

order by Maximum_revenue desc  , number_of_games asc




WITH genre_champions AS (
    SELECT 
        genre, 
        MAX(estimated_revenue_million_usd) AS max_genre_revenue
    FROM games
    GROUP BY genre
)


SELECT 
    g.title,
    g.genre,
    g.estimated_revenue_million_usd AS game_revenue,
    c.max_genre_revenue AS champion_revenue,
    
   
    ROUND(c.max_genre_revenue - g.estimated_revenue_million_usd, 2) AS gap_from_peak
    
FROM games g

JOIN genre_champions c ON g.genre = c.genre
ORDER BY g.genre ASC, gap_from_peak ASC;