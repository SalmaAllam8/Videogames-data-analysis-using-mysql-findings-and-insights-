/*
Does a higher launch price actually generate more lifetime revenue, or does it stifle early sales?
*/

SELECT 
    CASE 
        WHEN launch_price_usd  = 0 THEN 'Free-to-Play ($0)'
        WHEN launch_price_usd > 0 AND launch_price_usd <= 19.99 THEN 'Budget Tier (<$20)'
        WHEN launch_price_usd > 19.99 AND launch_price_usd <= 39.99 THEN 'Mid-Tier ($20-$40)'
        WHEN launch_price_usd > 39.99 AND launch_price_usd <= 59.99 THEN 'Standard Premium ($40-$60)'
        ELSE 'Next-Gen / Deluxe Premium (>$60)'
    END AS price_tier,
    COUNT(*) AS total_titles,
    ROUND(AVG(global_sales_million), 2) AS avg_units_sold_millions,
    ROUND(AVG(estimated_revenue_million_usd), 2) AS avg_revenue_millions,
    ROUND(AVG(user_score), 2) AS avg_player_sentiment,
 
    ROUND(AVG(metacritic_score) - AVG(user_score * 10), 2) AS price_backlash_delta
FROM videogames.games
WHERE launch_price_usd IS NOT NULL
GROUP BY 
price_tier 
ORDER BY MIN(launch_price_usd) ASC;