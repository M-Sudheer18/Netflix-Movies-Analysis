
-- Count the Number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;


-- Find the Most Common Rating for Movies and TV Shows

SELECT 
	type,
	rating
FROM 
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY type, rating
) 
as table1
WHERE ranking = 1


-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020


-- Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	STRING_TO_ARRAY(country, ',') as new_country
FROM netflix;

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country
FROM netflix;

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


-- Identify the Longest Movie
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix)


-- Find Content Added in the Last 6 Years
SELECT * 
FROM netflix
WHERE 
	TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years';


-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- List All TV Shows with More Than 5 Seasons
SELECT * 
FROM netflix
WHERE 
	type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1)::numeric > 5;



-- Count the Number of Content Items in Each Genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;



-- Find each year and the average numbers of content release in India on netflix.
-- Return TOP 5 Year with Highest avg Content Release
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*),
	ROUND(
	COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 ,
	2
	) as Avg_content_year
FROM netflix
WHERE country = 'India'
GROUP BY 1;



-- List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'


-- Find All Content Without a Director
SELECT * 
FROM netflix
WHERE 
	director IS NULL

-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT *
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;



-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies


SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in the Desription field.
-- Label Content containing these keywords as 'Bad' and all the other contents as 'Good'. 
-- Count How Many items Fall into each Group 
WITH Cat_table
AS
(
SELECT 
	*,
	CASE 
		WHEN description ILIKE '%kill%' 
			 OR 
			 description ILIKE '%violence%' THEN 'Bad_content'
		ELSE 'Good_content'
	End category
FROM netflix
)
SELECT 
	category,
	COUNT(*) as total_content
FROM Cat_table
GROUP BY 1












