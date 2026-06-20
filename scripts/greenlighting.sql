/*
which genres are oversaturated and which ones have a high financial ceiling but low competition. */

select genre , count(title) as number_of_games , max(estimated_revenue_million_usd) as Maximum_revenue 

from videogames,games

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





/*
we want to divide the market into 4 equal quadrants (Tiers) 
based entirely on revenue to see if player sentiment drops sharply as you move from low-earning indie
 tiers to the top-tier mega-earners. */


WITH tiered_games AS (
    SELECT 
        title,
        estimated_revenue_million_usd,
        user_score,
        NTILE(4) OVER (ORDER BY estimated_revenue_million_usd DESC) AS revenue_tier
    FROM games
    WHERE estimated_revenue_million_usd IS NOT NULL AND user_score IS NOT NULL
)
SELECT 
    revenue_tier,
    COUNT(*) AS total_games_in_tier,
    ROUND(MIN(estimated_revenue_million_usd), 2) AS min_revenue_in_tier,
    ROUND(MAX(estimated_revenue_million_usd), 2) AS max_revenue_in_tier,
    ROUND(AVG(user_score), 2) AS avg_player_sentiment
FROM tiered_games
GROUP BY revenue_tier
ORDER BY revenue_tier ASC;



/*
 "Top 3 Greenlight Recommendations" report. For each genre , the top 3 most profitable combinations
  of distribution_model (Game Pass vs. Premium) and monetization strategy.
 */

WITH ranked_strategies AS (
    SELECT 
        genre,
        CASE 
            WHEN game_pass_available = 1 AND (microtransactions = 1 OR loot_boxes = 1) THEN 'Game Pass + Live-Service'
            WHEN game_pass_available = 1 AND (microtransactions = 0 AND loot_boxes = 0) THEN 'Game Pass + Premium'
            WHEN game_pass_available = 0 AND (microtransactions = 1 OR loot_boxes = 1) THEN 'Purchase-Only + Live-Service'
            ELSE 'Traditional Purchase-Only'
        END AS strategic_model,
        ROUND(AVG(estimated_revenue_million_usd), 2) AS avg_revenue_million,
        
        
        ROW_NUMBER() OVER (
            PARTITION BY genre 
            ORDER BY AVG(estimated_revenue_million_usd) DESC
        ) AS strategy_rank

    FROM games
    GROUP BY genre, game_pass_available, microtransactions, loot_boxes
)


SELECT 
    genre,
    strategy_rank,
    strategic_model,
    avg_revenue_million
FROM ranked_strategies
WHERE strategy_rank <= 2
ORDER BY genre ASC, strategy_rank ASC;



