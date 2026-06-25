/*
 Does winning or being nominated for Game of the Year actually translate to a significant revenue lift, or is it just a vanity metric?
 */

/* "I assigned these weights based on typical GOTY voting criteria */

WITH goty_metrics AS (
    SELECT 
        title,
        genre,
        metacritic_score,
        user_score,
        global_sales_million,
        estimated_revenue_million_usd,
     
        CASE WHEN metacritic_score >= 90 THEN 40 
             WHEN metacritic_score >= 80 THEN 20 ELSE 0 END AS critic_points,
             
        CASE WHEN user_score >= 8.5 THEN 30 
             WHEN user_score >= 7.5 THEN 15 ELSE 0 END AS player_points
             
      
    FROM videogames.games
    WHERE metacritic_score IS NOT NULL AND user_score IS NOT NULL AND global_sales_million IS NOT NULL
) ,
goty_metrics_classified AS  (SELECT 
    title,
    genre,
    metacritic_score,
    user_score,
    global_sales_million,
     estimated_revenue_million_usd,
    (critic_points + player_points ) AS goty_probability_score,
    

    CASE 
        WHEN (critic_points + player_points ) >= 70 THEN 'Elite Contender (90%+)'
        WHEN (critic_points + player_points  )>= 35 THEN 'Strong Nominee (60%-89%)'
        WHEN (critic_points + player_points ) >= 30 THEN 'Niche/Cult Classic'
        ELSE 'Mainstream Commercial/Flop'
    END AS goty_tier

FROM goty_metrics
ORDER BY goty_probability_score DESC, global_sales_million desc)
SELECT 
    goty_tier,
    COUNT(*) AS total_games,
    ROUND(AVG(estimated_revenue_million_usd), 2) AS avg_revenue,
    ROUND(MAX(estimated_revenue_million_usd), 2) AS peak_revenue
FROM goty_metrics_classified
GROUP BY goty_tier
ORDER BY avg_revenue DESC;





