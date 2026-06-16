/*
which genres are oversaturated and which ones have a high financial ceiling but low competition. */

select genre , count(title) as number_of_games , max(estimated_revenue_million) as Maximum_revenue 

from videogames.games
