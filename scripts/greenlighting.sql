/*
which genres are oversaturated and which ones have a high financial ceiling but low competition. */

select genre , count(title) as number_of_games , max(estimated_revenue_million_usd) as Maximum_revenue 

from games

group by genre 
having  max(estimated_revenue_million_usd) > (
    SELECT AVG(estimated_revenue_million_usd) FROM games
)

order by Maximum_revenue desc  , number_of_games asc
