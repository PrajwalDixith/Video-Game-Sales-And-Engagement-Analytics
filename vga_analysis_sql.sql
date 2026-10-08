-- =================================================================
--   games.csv (Game Metadata Only)
-- =================================================================
-- 1. What are the top-rated games by user reviews? 
     #Top-rated games by user reviews (with a minimum review threshold to avoid 1-review skew)
SELECT Title, Rating, Number_of_Reviews, Plays
FROM clean_games
WHERE Number_of_Reviews > 100
ORDER BY Rating DESC, Number_of_Reviews DESC
LIMIT 10;

-- 2. Which developers (Teams) have the highest average ratings?  
	#Developers (Teams) with the highest average ratings (at least 2 games)
SELECT Team, ROUND(AVG(Rating), 2) AS avg_rating, COUNT(*) AS games_released
FROM clean_games
WHERE Team <> 'Unknown'
GROUP BY Team
HAVING COUNT(*) >= 2
ORDER BY avg_rating DESC, games_released DESC
LIMIT 10;
       
-- 3. What are the most common genres in the dataset? 
	#Most common genres in the dataset
SELECT Primary_Genre, COUNT(*) AS total_games
FROM clean_games
GROUP BY Primary_Genre
ORDER BY total_games DESC;

-- 4. Which games have the highest backlog compared to wishlist? 
      #Games with highest backlog compared to wishlist (ratio)
SELECT 
    Title, 
    Backlogs, 
    Wishlist, 
    ROUND(Backlogs / NULLIF(Wishlist, 0), 2) AS backlog_to_wishlist_ratio
FROM clean_games
WHERE Wishlist > 50
ORDER BY backlog_to_wishlist_ratio DESC
LIMIT 10;

-- 5. What is the game release trend across years?   
	#Game release trend across years
SELECT 
    YEAR(Release_Date) AS release_year, 
    COUNT(*) AS total_releases
FROM clean_games
WHERE Release_Date IS NOT NULL
GROUP BY release_year
ORDER BY release_year ASC;

-- 6. What is the distribution of user ratings? 
	#Distribution of user ratings (Bucket breakdown)
SELECT 
    FLOOR(Rating * 2) / 2 AS rating_bin, 
    COUNT(*) AS game_count
FROM clean_games
GROUP BY rating_bin
ORDER BY rating_bin DESC;

-- 7. What are the top 10 most wishlisted games?
	#Top 10 most wishlisted games
SELECT Title, Wishlist, Plays, Rating
FROM clean_games
ORDER BY Wishlist DESC
LIMIT 10;

-- 8. What’s the average number of plays per genre? 
	#Average number of plays per primary genre
SELECT 
    Primary_Genre, 
    ROUND(AVG(Plays), 0) AS avg_plays, 
    COUNT(*) AS game_count
FROM clean_games
GROUP BY Primary_Genre
ORDER BY avg_plays DESC;

-- 9. Which developer studios are the most productive and impactful? 
	#Most productive and impactful developer studios
SELECT 
    Team, 
    COUNT(*) AS total_games, 
    SUM(Plays) AS total_plays, 
    ROUND(AVG(Rating), 2) AS avg_rating
FROM clean_games
WHERE Team <> 'Unknown'
GROUP BY Team
ORDER BY total_games DESC, total_plays DESC
LIMIT 10;



-- =================================================================
--    vgsales.csv (Sales Data Only) 
-- =================================================================
-- 10. Which region generates the most game sales? 
	#Which region generates the most game sales?
SELECT 
    ROUND(SUM(NA_Sales), 2) AS total_na_sales,
    ROUND(SUM(EU_Sales), 2) AS total_eu_sales,
    ROUND(SUM(JP_Sales), 2) AS total_jp_sales,
    ROUND(SUM(Other_Sales), 2) AS total_other_sales,
    ROUND(SUM(Global_Sales), 2) AS total_global_sales
FROM clean_vgsales;

-- 11. What are the best-selling platforms?
	#Best-selling platforms by global sales
SELECT 
    Platform, 
    COUNT(*) AS total_titles, 
    ROUND(SUM(Global_Sales), 2) AS total_global_sales
FROM clean_vgsales
GROUP BY Platform
ORDER BY total_global_sales DESC
LIMIT 10;

-- 12. What’s the trend of game releases and sales over years? 
	#Trend of game releases and sales over years
SELECT 
    Year, 
    COUNT(*) AS titles_released, 
    ROUND(SUM(Global_Sales), 2) AS global_sales_millions
FROM clean_vgsales
GROUP BY Year
ORDER BY Year ASC;

-- 13. Who are the top publishers by sales? 
	#Top publishers by global sales
SELECT 
    Publisher, 
    COUNT(*) AS titles, 
    ROUND(SUM(Global_Sales), 2) AS total_global_sales
FROM clean_vgsales
WHERE Publisher <> 'Unknown'
GROUP BY Publisher
ORDER BY total_global_sales DESC
LIMIT 10;

-- 14. Which games are the top 10 best-sellers globally? 
	#Top 10 best-selling games globally
SELECT 
    'Rank', 'Name', Platform, 
    'Year', 
    Genre, 
    Publisher, 
    Global_Sales
FROM clean_vgsales
ORDER BY Global_Sales DESC
LIMIT 10;

-- 15. How do regional sales compare for specific platforms? 
	#Regional sales comparison for specific top platforms (e.g., PS2, X360, PS3, Wii)
SELECT 
    Platform,
    ROUND(SUM(NA_Sales), 2) AS na_sales,
    ROUND(SUM(EU_Sales), 2) AS eu_sales,
    ROUND(SUM(JP_Sales), 2) AS jp_sales,
    ROUND(SUM(Other_Sales), 2) AS other_sales,
    ROUND(SUM(Global_Sales), 2) AS total_sales
FROM clean_vgsales
GROUP BY Platform
ORDER BY total_sales DESC
LIMIT 8;
      
-- 16. How has the market evolved by platform over time? 
	#How the market evolved by platform over time (Decade / Multi-year view)
SELECT 
    Year, 
    Platform, 
    ROUND(SUM(Global_Sales), 2) AS total_platform_sales
FROM clean_vgsales
WHERE Year >= 2000
GROUP BY Year, Platform
ORDER BY Year DESC, total_platform_sales DESC;

-- 17. What are the regional genre preferences? 
	#Regional genre preferences
SELECT 
    Genre,
    ROUND(SUM(NA_Sales), 2) AS na_sales,
    ROUND(SUM(EU_Sales), 2) AS eu_sales,
    ROUND(SUM(JP_Sales), 2) AS jp_sales,
    ROUND(SUM(Global_Sales), 2) AS global_sales
FROM clean_vgsales
GROUP BY Genre
ORDER BY global_sales DESC;

-- 18. What’s the yearly sales change per region? 
	#Yearly sales change per region
SELECT 
    Year,
    ROUND(SUM(NA_Sales), 2) AS na_yearly_sales,
    ROUND(SUM(EU_Sales), 2) AS eu_yearly_sales,
    ROUND(SUM(JP_Sales), 2) AS jp_yearly_sales
FROM clean_vgsales
GROUP BY Year
ORDER BY Year ASC;

-- 19. What is the average sales per publisher?        
	#Average sales per publisher (minimum 10 releases)
SELECT 
    Publisher,
    COUNT(*) AS total_games,
    ROUND(AVG(Global_Sales), 3) AS avg_sales_per_title,
    ROUND(SUM(Global_Sales), 2) AS total_sales
FROM clean_vgsales
WHERE Publisher <> 'Unknown'
GROUP BY Publisher
HAVING COUNT(*) >= 10
ORDER BY avg_sales_per_title DESC
LIMIT 10;

-- 20. What are the top 5 best-selling games per platform?
	#Top 5 best-selling games per top platform (Using Window Function)
WITH RankedPlatformGames AS (
    SELECT 
        Name, 
        Platform, 
        Global_Sales,
        ROW_NUMBER() OVER(PARTITION BY Platform ORDER BY Global_Sales DESC) AS platform_rank
    FROM clean_vgsales
)
SELECT Platform, platform_rank, Name, Global_Sales
FROM RankedPlatformGames
WHERE platform_rank <= 5 AND Platform IN ('PS2', 'X360', 'PS3', 'WII', 'DS', 'PC')
ORDER BY Platform, platform_rank;

 
-- =================================================================
--       Merged Dataset (Sales + Engagement + Ratings) 
-- =================================================================
-- 21. Which game genres generate the most global sales? 
	 #Game genres generating the most global sales in merged data
SELECT 
    Genre, 
    COUNT(*) AS title_count, 
    ROUND(SUM(Global_Sales), 2) AS total_global_sales,
    ROUND(AVG(Rating), 2) AS avg_user_rating
FROM clean_merged_vgsales
GROUP BY Genre
ORDER BY total_global_sales DESC;

-- 22. How does user rating affect global sales? 
	#How user rating affects global sales (Rating Tier breakdown)
SELECT 
    CASE 
        WHEN Rating >= 4.5 THEN '4.5 - 5.0 (Masterpiece)'
        WHEN Rating >= 4.0 THEN '4.0 - 4.4 (Great)'
        WHEN Rating >= 3.5 THEN '3.5 - 3.9 (Good)'
        WHEN Rating >= 3.0 THEN '3.0 - 3.4 (Average)'
        ELSE 'Below 3.0 (Poor)'
    END AS rating_tier,
    COUNT(*) AS number_of_titles,
    ROUND(AVG(Global_Sales), 2) AS avg_sales,
    ROUND(SUM(Global_Sales), 2) AS total_sales
FROM clean_merged_vgsales
GROUP BY rating_tier
ORDER BY avg_sales DESC;

-- 23. Which platforms have the most games with high ratings (e.g., above 4)?  
	#Platforms with the most games rated above 4.0
SELECT 
    Platform, 
    COUNT(*) AS high_rated_games,
    ROUND(AVG(Rating), 2) AS avg_platform_rating
FROM clean_merged_vgsales
WHERE Rating >= 4.0
GROUP BY Platform
ORDER BY high_rated_games DESC;

-- 24. What’s the trend of releases and sales over time? 
	#Trend of releases, ratings, and sales over time
SELECT 
    Year, 
    COUNT(*) AS titles_released, 
    ROUND(AVG(Rating), 2) AS avg_rating,
    ROUND(SUM(Global_Sales), 2) AS total_sales
FROM clean_merged_vgsales
GROUP BY Year
ORDER BY Year ASC;

-- 25. Do highly wishlisted games lead to more sales? 
	#Do highly wishlisted games lead to more sales?
SELECT 
    CASE 
        WHEN Wishlist >= 3000 THEN '3k+ Wishlists'
        WHEN Wishlist >= 1000 THEN '1k - 3k Wishlists'
        WHEN Wishlist >= 500  THEN '500 - 1k Wishlists'
        ELSE '< 500 Wishlists'
    END AS wishlist_bracket,
    COUNT(*) AS total_games,
    ROUND(AVG(Global_Sales), 2) AS avg_global_sales,
    ROUND(SUM(Global_Sales), 2) AS total_sales
FROM clean_merged_vgsales
GROUP BY wishlist_bracket
ORDER BY avg_global_sales DESC;

-- 26. Which genres have the highest engagement but lowest sales?  
	#Genres with highest engagement (Plays) but lowest sales
SELECT 
    Genre,
    ROUND(AVG(Plays), 0) AS avg_plays,
    ROUND(AVG(Global_Sales), 2) AS avg_sales,
    ROUND(AVG(Plays) / NULLIF(AVG(Global_Sales), 0), 0) AS engagement_to_sales_ratio
FROM clean_merged_vgsales
GROUP BY Genre
ORDER BY engagement_to_sales_ratio DESC;

-- 27. Do highly listed games (wishlist/backlogs) correlate with better ratings? 
	#Do highly listed games (Wishlist + Backlogs) correlate with better ratings?
SELECT 
    CASE 
        WHEN (Wishlist + Backlogs) >= 5000 THEN 'Very High (5000+)'
        WHEN (Wishlist + Backlogs) >= 2000 THEN 'High (2000-4999)'
        WHEN (Wishlist + Backlogs) >= 500  THEN 'Moderate (500-1999)'
        ELSE 'Low (<500)'
    END AS listed_status,
    COUNT(*) AS game_count,
    ROUND(AVG(Rating), 2) AS avg_rating
FROM clean_merged_vgsales
GROUP BY listed_status
ORDER BY avg_rating DESC;

-- 28. How does user engagement differ across genres? 
	#How user engagement differs across genres
SELECT 
    Genre,
    ROUND(AVG(Plays), 0) AS avg_plays,
    ROUND(AVG(Backlogs), 0) AS avg_backlogs,
    ROUND(AVG(Wishlist), 0) AS avg_wishlist
FROM clean_merged_vgsales
GROUP BY Genre
ORDER BY avg_plays DESC;

-- 29. What are the top-performing combinations of Genre + Platform? 
	#Top-performing combinations of Genre + Platform
SELECT 
    Genre, 
    Platform, 
    COUNT(*) AS titles, 
    ROUND(SUM(Global_Sales), 2) AS total_sales,
    ROUND(AVG(Rating), 2) AS avg_rating
FROM clean_merged_vgsales
GROUP BY Genre, Platform
HAVING COUNT(*) >= 3
ORDER BY total_sales DESC
LIMIT 10;

-- 30. What does a regional sales heatmap by genre reveal? 
	#Regional sales breakdown by genre (Heatmap matrix query)
SELECT 
    Genre,
    ROUND(SUM(NA_Sales), 2) AS na_sales,
    ROUND(SUM(EU_Sales), 2) AS eu_sales,
    ROUND(SUM(JP_Sales), 2) AS jp_sales,
    ROUND(SUM(Other_Sales), 2) AS other_sales,
    ROUND(SUM(Global_Sales), 2) AS global_sales
FROM clean_merged_vgsales
GROUP BY Genre
ORDER BY global_sales DESC;
