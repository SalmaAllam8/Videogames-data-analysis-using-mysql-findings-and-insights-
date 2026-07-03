#  Video Game Industry


<img width="1774" height="887" alt="db70a582-2aa2-471c-ac3f-c0841b90beb1" src="https://github.com/user-attachments/assets/95b743b3-6950-47d3-92bd-077bcfac0ec7" />

*End-to-End Data Analysis using SQL, Python, and Machine Learning*
---
## Introduction

The global video game industry has become one of the fastest-growing sectors of the entertainment market. According to recent industry reports, global revenue is projected to reach approximately $293 billion by 2027, reflecting sustained growth driven by technological innovation and increasing consumer demand.

Modern video games are no longer targeted solely at children. Players span all age groups and demographics, while many AAA titles now rival Hollywood productions in both development budgets and production quality.

Despite its economic significance, the video game industry has received comparatively limited attention within academic data analysis. This project explores historical trends, publisher performance, genre evolution, and commercial success through exploratory data analysis, feature engineering, and machine learning techniques.



## Business Questions answered 

* Which genres dominated each gaming era?
* How has the gaming industry evolved over the last four decades?
* Which publishers consistently produce highly rated games?
* How long do publishers survive after entering the market?
* Which games depend most on North American sales?
* Which games show the greatest disagreement between critics and players?
* How common are DLC, microtransactions, and loot boxes?
* Which games are statistical outliers according to Isolation Forest?
* What was the industry's strongest three-year commercial period?
* Which modern console exclusives combined critical acclaim with commercial success?


  # Questions and analysis using SQL
  
  <img width="1680" height="945" alt="What_is_SQL_Database" src="https://github.com/user-attachments/assets/4f1ab479-c86d-4dad-a245-4a02e3930688" />


 ## 1. The Power of Monetization


<img width="582" height="107" alt="Revenue comparison by monetization status" src="https://github.com/user-attachments/assets/955e82a4-10ba-4d93-8394-a59ae61a82b8" />

> **Key Takeaway:** As shown above, monetized games generate a significantly higher estimated revenue than titles with no post-launch monetization.

### What type of monetization makes the most revenue?
To dig deeper, the data was segmented by monetization models to find out which specific strategy yields the highest return.

``` sql []
SELECT 
    CASE 
        WHEN dlc_released = 0 AND microtransactions = 0 AND loot_boxes = 0 THEN 'Pure Premium (No Monetization)'
        WHEN dlc_released = 1 AND microtransactions = 0 AND loot_boxes = 0 THEN 'Expansion Model (DLC Only)'
        WHEN dlc_released = 0 AND microtransactions = 1 AND loot_boxes = 0 THEN 'Microtransactions Only'
        WHEN dlc_released = 0 AND microtransactions = 0 AND loot_boxes = 1 THEN 'Loot Boxes Only'
        WHEN dlc_released = 1 AND microtransactions = 1 AND loot_boxes = 0 THEN 'Hybrid Premium (DLC + MTX)'
        WHEN dlc_released = 1 AND microtransactions = 0 AND loot_boxes = 1 THEN 'Hybrid Premium (DLC + Loot Boxes)'
        WHEN dlc_released = 0 AND microtransactions = 1 AND loot_boxes = 1 THEN 'Live Service / F2P Core (MTX + Loot Boxes)'
        WHEN dlc_released = 1 AND microtransactions = 1 AND loot_boxes = 1 THEN 'Full Monetization (DLC + MTX + Loot Boxes)'
        ELSE 'Other'
    END AS monetization_strategy,
    COUNT(*) AS total_titles,
    ROUND(SUM(estimated_revenue_million_usd ), 2) AS total_revenue_million,
    ROUND(AVG(estimated_revenue_million_usd ), 2) AS avg_revenue_per_title,
    ROUND(AVG(global_sales_million), 2) AS avg_units_sold_million
FROM videogames.games g 
GROUP BY 
  monetization_strategy
ORDER BY 
    avg_revenue_per_title DESC;
```

<img width="1383" height="252" alt="Breakdown of monetization models by revenue" src="https://github.com/user-attachments/assets/734248db-9b8e-4ad8-a3d1-dcc7a88855fb" />

``` sql []
SELECT 
    CASE 
        WHEN dlc_released = 0 AND microtransactions = 0 AND loot_boxes = 0 THEN 'Pure Premium (No Monetization)'
        WHEN dlc_released = 1 AND microtransactions = 0 AND loot_boxes = 0 THEN 'Traditional DLC Model (Expansions Only)'
        WHEN dlc_released = 0 AND (microtransactions = 1 OR loot_boxes = 1) THEN 'Pure Live-Service Model (MTX/Loot Boxes Only)'
        WHEN dlc_released = 1 AND (microtransactions = 1 OR loot_boxes = 1) THEN 'Hybrid Model (DLC + Live-Service Double-Dip)'
        ELSE 'Other'
    END AS business_model,
    COUNT(*) AS total_titles,
    ROUND(SUM(estimated_revenue_million_usd ), 2) AS total_revenue_million,
    ROUND(AVG(estimated_revenue_million_usd ), 2) AS avg_revenue_per_title,
    ROUND(AVG(global_sales_million), 2) AS avg_units_sold_million
FROM videogames.games
GROUP BY business_model
ORDER BY total_revenue_million DESC;
```
<img width="1400" height="261" alt="Critic vs User score for basic monetization" src="https://github.com/user-attachments/assets/6d735e69-ee92-4345-9d15-d16d37b096c4" />

---

##  2. The Player Backlash (Sentiment Analysis)

Does extracting more revenue come at the cost of player happiness? First, let's look at the baseline difference in criticism between monetized and non-monetized games:


 there is almost no massive difference between the aggregate scores of standard monetized vs. non-monetized groups. However, when we isolate **Intense Monetization** (games pushing DLC, microtransactions, *and* loot boxes simultaneously), the true friction appears:

<img width="548" height="162" alt="Monetization intensity tiers" src="https://github.com/user-attachments/assets/f0ce16cb-73a1-4f70-af88-801d7cffbaa7" />
<img width="762" height="192" alt="Sentiment delta for intense monetization" src="https://github.com/user-attachments/assets/14cea59b-df0c-42ad-bad0-f9cb35f19b89" />

> **The Sentiment Delta:** Games with **Intense Monetization** exhibit the highest gap between Metacritic scores (critics) and user scores (players). This indicates a strong player backlash. When users face heavy in-game monetization, their expectations skyrocket because of the financial investment required, making them far more likely to "review-bomb" a game if those expectations aren't perfectly met.

---

##  3. The Subscription Model: Game Pass vs. Direct Sales

Shifting from how games monetize to how players access them, we analyzed the impact of subscription services. On average, games available on Game Pass earn slightly more revenue overall than purchase-only titles.

<img width="610" height="157" alt="Game Pass vs Purchase-only baseline revenue" src="https://github.com/user-attachments/assets/eec67c03-a17d-4d2f-9a13-5c952086df07" />

### What if your game gets bad reviews?


<img width="1081" height="157" alt="Revenue for low-scoring titles by model" src="https://github.com/user-attachments/assets/21f7938b-8907-49e6-b541-dd42d5a9ab1c" />

The data shows that poorly-reviewed games still manage to achieve decent estimated revenue if they are backed by Game Pass availability, protecting publishers from the steep financial drop-off suffered by poorly-reviewed purchase-only titles.

---

## 4. Genre-Specific Performance

Not all game types react to subscription services the same way. This breakdown isolates financial performance by genre across both distribution pathways:

<img width="962" height="721" alt="Genre breakdown across Game Pass and Premium" src="https://github.com/user-attachments/assets/0196888a-56f1-4287-b901-92981321529e" />

---

#  Conclusion

1. **The Subscription Advantage:** The vast majority of game genres perform better financially when placed on subscription services like Game Pass, leveraging high player volume.
2. **The Revenue :** Post-launch monetization features drastically increase a game's total revenue ceiling compared to pure premium models.
3. **The Risk:** Publishers must proceed with caution. **Intense Monetization** creates a severe inflation in player expectations. If a game pushes microtransactions and loot boxes too aggressively, it triggers heavy community backlash, resulting in cratered user scores despite positive critic acclaim.




## Greenlighting New Games 

This section shifts our focus from historic performance to strategic, forward-looking market placement—helping studio executives determine where to invest development capital next.

---

 ## 5 — Scanning the Market for Opportunities

Before pitching a new game concept, we must evaluate market saturation against financial ceilings. We look for high-ceiling, low-competition targets.

<img width="606" height="488" alt="Market Opportunity Scan Matrix" src="https://github.com/user-attachments/assets/58d8aeea-9781-4b41-bba5-8560d47c695c" />

> **Key Market Signal:** As shown above, **Sandbox games** represent a massive market anomaly—they have the lowest competitor density (fewest games produced) yet yield the highest maximum revenue potential. 

---

 ## 6 — Quantifying the Revenue Gap

Every genre has a "Genre Champion" that represents the absolute market ceiling. To understand how much market share is left on the table by other titles, this query uses a **Common Table Expression (CTE)** to calculate exactly how far below the peak revenue each game sits.

```sql []
WITH genre_champions AS (
    SELECT 
        genre, 
        MAX(estimated_revenue_million_usd) AS max_genre_revenue
    FROM videogames.games
    GROUP BY genre
)
SELECT 
    g.title,
    g.genre,
    g.estimated_revenue_million_usd AS game_revenue,
    c.max_genre_revenue AS champion_revenue,
    ROUND(c.max_genre_revenue - g.estimated_revenue_million_usd, 2) AS gap_from_peak
FROM videogames.games g
JOIN genre_champions c ON g.genre = c.genre
ORDER BY g.genre ASC, gap_from_peak ASC;

```

<img width="940" height="738" alt="image" src="https://github.com/user-attachments/assets/33892bb2-62a5-4255-ad79-51076e0b1b1d" />


## 7 — The Monetization Tier Bracket (Revenue vs. Player Sentiment)
To evaluate whether massive financial performance directly damages consumer trust, I used the NTILE(4) window function to divide the entire market into four perfectly equal performance quadrants based purely on revenue.

```sql []

WITH tiered_games AS (
    SELECT 
        title,
        estimated_revenue_million_usd,
        user_score,
        NTILE(4) OVER (ORDER BY estimated_revenue_million_usd DESC) AS revenue_tier
    FROM videogames.games
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

```
<img width="1117" height="150" alt="image" src="https://github.com/user-attachments/assets/de4e6272-8dac-43ac-8b70-610b03e03856" />

 ##  8 — Top Strategic Greenlight Recommendations
By utilizing ROW_NUMBER() partitioned by genre, this analysis extracts only the Top 2 most profitable combinations of distribution models and monetization frameworks for every single genre in the database.

```sql []

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
    FROM videogames.games
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
```

<img width="800" height="731" alt="image" src="https://github.com/user-attachments/assets/370cef31-754a-4e94-a574-9c081605969d" />




# Questions and analysis using python 

<img width="612" height="387" alt="1_sE8va-oejfkwN21mIo1UKQ" src="https://github.com/user-attachments/assets/77790945-3444-46f5-8763-11bda63b96bf" />

 **[Open the Jupyter Notebook](notebook_analysis.ipynb)**



 # Business recommendation 

 <img width="8000" height="5000" alt="6685" src="https://github.com/user-attachments/assets/3bd3f7fd-b72c-428b-a06e-a4071f0d4a1a" />


## Genres Investments

  <img width="1156" height="477" alt="image" src="https://github.com/user-attachments/assets/d42e17e2-7c07-4509-870e-d873d5977a90" />

 >Action and Role-Playing have demonstrated compounding growth across all four gaming eras, making them the lowest-risk genres for greenlight investment. Sandbox, despite its small historical footprint (75 titles in the 8-Bit era vs. 155 today), shows accelerating adoption — consistent with our earlier Blue Ocean finding that it carries the highest revenue ceiling per title. Studios should treat Sandbox as a high-upside, lower-competition bet alongside their core Action/RPG slate. Genres like Rhythm and Visual Novel show no meaningful growth across eras and should be deprioritized unless tied to a specific IP strategy.





<img width="861" height="515" alt="image" src="https://github.com/user-attachments/assets/5f386350-a245-498e-a747-a0532d2e98f4" />

>The disagreement runs in both directions and each direction signals a different strategic risk. Games like eFootball 2023 and Mortal Kombat IV were underrated by critics but embraced by players — suggesting review-bombing or niche audience bias; publishers shouldn't panic-cut marketing budgets based on Metacritic alone. Conversely, games like Call of Duty: Rising Sun and Counter-Strike Origins received strong critical reception but low player scores — a classic sign of overpromising in marketing or post-launch monetization backlash. Studios should treat a large critic-user gap as an early warning signal requiring investigation, not just a footnote in a post-launch report.




<img width="1089" height="790" alt="__results___80_1" src="https://github.com/user-attachments/assets/fcacd8c1-6bea-475b-a995-cc5cafc4bae0" />


>Publishers entering the Sandbox genre should benchmark against Japanese and American studios, which average 99.81M and 83.54M in global sales respectively — far exceeding any other region-genre combination in the dataset. For Sports, Battle Royale, and Shooter, the market is heavily consolidated around the same three regions, making new entrants from Europe or Canada structurally disadvantaged. Smaller publishers should target underserved genre-region gaps — particularly Action and Role-Playing where European publishers show competitive average sales — rather than competing directly in Japan/USA-dominated categories.

<img width="1005" height="549" alt="image" src="https://github.com/user-attachments/assets/bfb21ff2-94c7-4675-9554-855aa28b0b13" />

>The survival curve appears stable at ~100% for 30 years before a sharp drop to ~48% — however this cliff likely reflects data censoring rather than a true industry pattern. Publishers debuting after the mid-1990s don't yet have complete lifecycle data, making long-term survival conclusions unreliable with this dataset alone. A proper survival analysis would require time-to-exit data from an industry database like Crunchbase or Bloomberg.

>Note: lifetime here is measured as the span between a publisher's first and last recorded release in the dataset. Publishers still active at the dataset's cutoff year are indistinguishable from those that exited — a limitation that affects the curve's right tail and the cliff visible around year 30.

<img width="1175" height="547" alt="image" src="https://github.com/user-attachments/assets/c9f2530a-c7f4-408a-9385-9811c32aecdb" />

>The video game industry has never been larger than it is right now — the peak era in this dataset is the present, not a historical golden age. The 3-year rolling total has grown nearly 3x since 2008, driven by two distinct acceleration events: the online/mobile revolution (~2008) and the post-2020 expansion. For studios deciding when to greenlight a new title, this trend carries a clear signal — the market you're launching into is larger than any market that has ever existed before. New IP launches carry lower baseline risk than historical comparisons suggest, and studios that delay development cycles risk missing a window of compounding market growth.








