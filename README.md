# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves an analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. This README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Netflix Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

-- Verify the data load
SELECT * FROM netflix;
SELECT COUNT(*) FROM netflix;
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
    type,
    rating
FROM 
(
    SELECT 
        type,
        rating,
        COUNT(*),
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS table1
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE 
    type = 'Movie'
    AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items. The `country` column holds comma-separated values, so `STRING_TO_ARRAY` and `UNNEST` split them into one row per country before counting.

### 5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
WHERE 
    type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 6 Years

```sql
SELECT * 
FROM netflix
WHERE 
    TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years';
```

**Objective:** Retrieve content added to Netflix in the last 6 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * 
FROM netflix
WHERE 
    type = 'TV Show'
    AND SPLIT_PART(duration, ' ', 1)::numeric > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10. Find Each Year and the Average Number of Content Releases in India on Netflix

Return the top 5 years with the highest average content release.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,
        2
    ) AS avg_content_year
FROM netflix
WHERE country = 'India'
GROUP BY 1;
```

**Objective:** Calculate each year's share of India's content releases on Netflix, based on the year the content was added.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';
```

**Objective:** Retrieve all content classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE 
    casts ILIKE '%Salman Khan%'
    AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Find the movies featuring 'Salman Khan' released in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
    COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced content.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

Label content containing these keywords in the description as 'Bad' and all other content as 'Good', then count how many items fall into each group.

```sql
WITH Cat_table AS
(
    SELECT 
        *,
        CASE 
            WHEN description ILIKE '%kill%' 
                 OR description ILIKE '%violence%' THEN 'Bad_content'
            ELSE 'Good_content'
        END AS category
    FROM netflix
)
SELECT 
    category,
    COUNT(*) AS total_content
FROM Cat_table
GROUP BY 1;
```

**Objective:** Categorize content as 'Bad_content' if its description contains 'kill' or 'violence', and 'Good_content' otherwise. Count the number of items in each category.

## SQL Concepts Used

- Aggregation: `COUNT`, `MAX`, `ROUND`, `GROUP BY`, `ORDER BY`, `LIMIT`
- Window functions: `RANK() OVER (PARTITION BY ...)`
- Subqueries and CTEs (`WITH`)
- String functions: `STRING_TO_ARRAY`, `UNNEST`, `SPLIT_PART`, `ILIKE`
- Date functions: `TO_DATE`, `EXTRACT`, `CURRENT_DATE`, `INTERVAL`
- Conditional logic: `CASE WHEN`
- Type casting: `::numeric`

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** The most common rating for each content type shows the audience the catalog mainly targets.
- **Geographical Insights:** The top countries and India's yearly share of content highlight regional content distribution.
- **Talent Insights:** Director, actor, and genre queries reveal who and what appears most often in the catalog.
- **Content Categorization:** Categorizing content by keywords in the description helps in understanding the nature of the content available on Netflix.

This analysis provides a view of Netflix's content and can help inform content strategy and decision-making.

## How to Run

1. Create a PostgreSQL database.
2. Run `Table.sql` to create the `netflix` table.
3. Import the Kaggle CSV into the `netflix` table.
4. Run the queries in `Process.sql`.

## Author - [Your Name]

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media:

- **YouTube**: [Add your channel link]
- **Instagram**: [Add your profile link]
- **LinkedIn**: [Add your profile link]
- **GitHub**: [Add your profile link]

Thank you for your support, and I look forward to connecting with you!
