USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 'director_mapping' AS Table_Name, count(*) AS Num_of_Rows 	-- To optimise query performance, count(*) is used instead of counting the no. of rows in PK column. count(*) 
FROM director_mapping												-- will give count of all rows, including NULL rows
    
UNION ALL															-- There is no scope of having duplicate row values in this case. So, used UNION ALL instead of UNION to optamise query performance.
SELECT 'genre' AS Table_Name, count(*) AS Num_of_Rows
FROM genre
    
UNION ALL
SELECT 'movie' AS Table_Name, count(*) AS Num_of_Rows
FROM movie

UNION ALL
SELECT 'names' AS Table_Name, count(*) AS Num_of_Rows
FROM names

UNION ALL
SELECT 'ratings' AS Table_Name, count(*) AS Num_of_Rows
FROM ratings

UNION ALL
SELECT 'role_mapping' AS Table_Name, count(*) AS Num_of_Rows
FROM role_mapping;    

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

/* 1- Created Common Table Expression(CTE) to house all count of null value in each column
   2- There is no scope of having duplicate row values in this case. So, used UNION ALL instead of UNION to optamise query performance.*/
   
WITH Null_Count_Table AS(  														
SELECT 'id' AS Column_Name,
		sum(CASE WHEN id IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL				  														 
SELECT 'title' AS Column_Name,
		sum(CASE WHEN title IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'year' AS Column_Name,
		sum(CASE WHEN year IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'date_published' AS Column_Name,
		sum(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'duration' AS Column_Name,
		sum(CASE WHEN duration IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'country' AS Column_Name,
		sum(CASE WHEN country IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'worlwide_gross_income' AS Column_Name,
		sum(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'languages' AS Column_Name,
		sum(CASE WHEN languages IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie

UNION ALL
SELECT 'production_company' AS Column_Name,
		sum(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM movie
)

/* This query will filter and show only the column names which have null values */
SELECT *
FROM Null_Count_Table
WHERE Null_Count>0;


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/* The total number of movies released each year */
SELECT
	Year, 
    COUNT(id) AS number_of_movies
FROM movie
GROUP BY 
	Year;

/* The total number of movies released -Month wise */
SELECT 
	MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM movie
GROUP BY month_num;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

/* Indexing the column which I am going to use within WHERE clause.*/

-- Index on country column
CREATE INDEX ind_country ON movie(country);

SELECT 
	COUNT(id) AS "Movies Produced in USA or India in 2019"
FROM movie
WHERE 
	year =2019 AND 
    (country LIKE "%USA%" OR country LIKE "%INDIA%");			-- As the country column has multiple comma separted values, use of %x% wild card is necessary to filter required values

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

/* Use of DISTINCT keyword can fetch the unique list of the genres  */
SELECT 
	DISTINCT genre   
FROM
	genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
	genre,
	COUNT(movie_id) AS Movies_Count
FROM 
	genre 	     
GROUP BY 
	genre
ORDER BY 
	Movies_Count DESC
LIMIT 1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH Movie_Genre_Table AS(								/*Created Common Table Expression(CTE) to find number of genre per movie id*/
SELECT movie_id,
	   COUNT(genre) AS Num_of_Genre	   
FROM genre 
GROUP BY movie_id
HAVING Num_of_Genre =1
)														/*Filtered CTE to count the number of movies belong to only one genre*/
SELECT 
	count(movie_id) AS Count_one_genre_movie
FROM 
	Movie_Genre_Table;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre,
	   ROUND(AVG(m.duration),2) AS avg_duration       
FROM 
	   genre AS g
	   LEFT JOIN
       movie AS m
       ON g.movie_id = m.id
GROUP BY 
	g.genre;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH movies_genre AS(									-- creating CTE to house movies count based on genre
SELECT genre,
	   COUNT(movie_id) AS movie_count,
       RANK() OVER w AS genre_rank
FROM
	genre 
GROUP BY 
	genre
WINDOW w as (ORDER BY COUNT(movie_id) DESC)				-- ranking genre based on number of movies.
)
SELECT *												-- Filtering thriller movies 
FROM movies_genre
WHERE genre = 'thriller';


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT	
	MIN(avg_rating) AS min_avg_rating,
	MAX(avg_rating) AS max_avg_rating,
	MIN(total_votes) AS min_total_votes,
	MAX(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating,
	MAX(median_rating) AS max_median_rating
FROM
	ratings;    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- Keep in mind that multiple movies can be at the same rank. You only have to find out the top 10 movies (if there are more than one movies at the 10th place, consider them all.)

WITH movie_ranking_table AS(			/* Creating CTE to store ranking of movies*/
SELECT
	m.title,
    r.avg_rating,
    RANK() OVER w AS movie_rank
FROM 
	movie AS m
LEFT JOIN
	ratings AS r
ON 
	m.id = r.movie_id
WINDOW w AS (ORDER BY r.avg_rating DESC)
)
SELECT	*							/* Finding Top 10 movies by applying filter on movie_rank*/
FROM	movie_ranking_table
WHERE	movie_rank<=10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT
	median_rating,
    COUNT(movie_id) AS movie_count
FROM
	ratings
GROUP BY 
	median_rating
ORDER BY 
	movie_count DESC;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

/* Indexing the columns which I am going to use within WHERE clause.*/

-- Index on avg_rating column in ratings table
CREATE INDEX ind_avg_ratig ON ratings(avg_rating);
-- Index on production_company column in movie table
CREATE INDEX ind_production_company ON movie(production_company);

/* Creating a CTE to rank the production companies*/
WITH high_rated_prod_company AS(
SELECT 											
	m.production_company,						
    COUNT(m.id) AS movie_count
FROM movie m 
	INNER JOIN ratings r 
    ON r.movie_id = m.id
WHERE 											-- Joined movie and rating tables to find count of movies produced by production companies
	r.avg_rating>8 AND							-- which have secured average rating more than 8
    m.production_company IS NOT NULL			/* As there are NULL values in column m.production_company, I have filtered the NULL values for analysis */
GROUP BY 
	m.production_company
), 
ranking_prod_company As(
SELECT *,									/* Creating a new column to house the production company rank based on number of hit movies they produced */
DENSE_RANK() OVER w AS prod_company_rank
FROM high_rated_prod_company
WINDOW w AS (ORDER BY movie_count DESC)
)
SELECT *									/* Finding Top production house based on ranking */
FROM ranking_prod_company
WHERE prod_company_rank <=1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/* Indexing the columns which I am going to use within WHERE clause.*/

-- Index on date_published column
CREATE INDEX ind_date_published ON movie(date_published);
-- Index on total_votes column
CREATE INDEX ind_total_votes ON ratings(total_votes);

-- joining three tables - movie, genre & ratings and then applying filters
SELECT 
	g.genre,
    COUNT(g.movie_id) AS movie_count
FROM
	genre g 
    INNER JOIN movie m ON m.id = g.movie_id
    INNER JOIN ratings r ON r.movie_id = m.id
WHERE
	m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
	AND m.country = "USA"  
    AND r.total_votes>1000
GROUP BY g.genre;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH movie_summary AS(											/* Creating a CTE to house movies having avg rating above 8.*/
SELECT
	m.title,
    r.avg_rating,
    g.genre
FROM
	movie m 
    INNER JOIN ratings r ON m.id = r.movie_id
    INNER JOIN genre g USING(movie_id)
    WHERE r.avg_rating >8
)
SELECT *														/* Filtering the movie_summary table for movies whose title starts with "The" */
FROM movie_summary
WHERE title REGEXP "^The";


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

/* Indexing the column which I am going to use within WHERE clause.*/

-- Index on median_rating column in ratings table
CREATE INDEX ind_median_rating ON ratings(median_rating);

SELECT
	COUNT(m.id) AS Num_of_Movies_with_MedRate_8
FROM
	movie m 
    INNER JOIN ratings r ON m.id = r.movie_id
WHERE 
	m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
	AND r.median_rating=8;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

       
SELECT 
	'Italian' AS Language, 
	SUM(total_votes) AS VOTES  
FROM 
	MOVIE AS m
	INNER JOIN RATINGS AS r ON m.id = r.movie_id
WHERE 
	languages LIKE '%Italian%'
GROUP BY 
	Language
    
UNION

SELECT 
	'German' AS Language, 
    SUM(total_votes) AS VOTES 
FROM 
	MOVIE AS m
	INNER JOIN RATINGS AS r ON m.id = r.movie_id
WHERE 
	languages LIKE '%German%'
GROUP BY 
	Language
ORDER BY 
	VOTES DESC;  

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

-- First row with descriptive column names
WITH Null_Count_namesTbl AS(  														/*Created Common Table Expression(CTE) to house all count of null value in each column*/
SELECT 'id' AS Column_Name,
		SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM names

UNION ALL				  															/*There is no scope of having duplicate row values in this case. So, used UNION ALL instead of UNION to optamise query performance.*/ 
SELECT 'name' AS Column_Name,
		sum(CASE WHEN name IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM names

UNION ALL
SELECT 'height' AS Column_Name,
		sum(CASE WHEN height IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM names

UNION ALL
SELECT 'date_of_birth' AS Column_Name,
		sum(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM names

UNION ALL
SELECT 'known_for_movies' AS Column_Name,
		sum(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END ) AS Null_Count
FROM names
)
																					/*Filtering column which have NULL values*/ 
SELECT *
FROM Null_Count_namesTbl
WHERE Null_Count>0;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH Top_three_Genre AS(															-- Creating CTE to get the top three genres based on the number of movies with an average rating greater than 8			
SELECT
	g.genre AS genre,
    COUNT(r.movie_id) AS Movies_Count
FROM
	ratings r 
    INNER JOIN genre g 
    USING(movie_id)
WHERE
	r.avg_rating>8
GROUP BY g.genre
ORDER BY Movies_Count DESC
LIMIT 3
),
Director_movie_count AS(															-- Creating CTE to calculate movie count for each director within the top three genres
SELECT
	n.name AS director_name,
    g.genre,
	COUNT(r.movie_id) AS Movies_Count
FROM
	names n
    INNER JOIN director_mapping d ON d.name_id = n.id
    INNER JOIN ratings r ON r.movie_id = d.movie_id
    INNER JOIN genre g ON g.movie_id = r.movie_id
WHERE
	r.avg_rating>8 AND
    g.genre IN (SELECT genre FROM Top_three_Genre)
GROUP BY 
	director_name,
    g.genre
),
Director_Aggregates AS (															-- Creating CTE to aggregate the total movie count for each director across the top genres
SELECT 
    director_name, 
    SUM(Movies_Count) AS Total_Movies_Count 
FROM 
	Director_Movie_Count 
GROUP BY
	director_name
)
SELECT																				-- Final SELECT to get the top three directors based on the total movie count
	director_name,
    Total_Movies_Count AS Movies_Count
FROM Director_Aggregates
ORDER BY 
	movies_count DESC
LIMIT 3;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

CREATE INDEX ind_category ON role_mapping(category);

SELECT 
	n.name as actor_name,
	COUNT(rm.movie_id) As movie_count
FROM
	names n 
    INNER JOIN role_mapping rm ON n.id = rm.name_id
    INNER JOIN ratings r ON r.movie_id = rm.movie_id
WHERE 
	rm.category = "actor" AND r.median_rating >=8
GROUP BY
	actor_name
ORDER BY movie_count DESC
LIMIT 2;


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH Prodduction_Comp_Summary AS(
SELECT 
	m.production_company,
    SUM(r.total_votes) AS vote_count,
    RANK() OVER w AS prod_comp_rank
FROM
	movie m
    INNER JOIN
    ratings r ON m.id = r.movie_id
GROUP BY m.production_company
WINDOW W AS (ORDER BY SUM(r.total_votes) DESC)

)
SELECT *																				-- Finding top three production houses in the world
FROM Prodduction_Comp_Summary
WHERE prod_comp_rank <=3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH Indian_actor_summary AS (																	-- Creating a CTE to house all INDIAN ACTORS
    SELECT  
        n.name AS actor_name,
        m.id AS movie_id,
        r.avg_rating,
        r.total_votes
    FROM
        names n
		INNER JOIN role_mapping rm ON n.id = rm.name_id
		INNER JOIN ratings r ON r.movie_id = rm.movie_id
        INNER JOIN movie m ON m.id = rm.movie_id
    WHERE 
        rm.category = 'actor'
        AND m.country LIKE '%India%'
),
actor_aggregates AS (																			-- Calculating Indian actors deatails and keeping in a CTE
    SELECT
        actor_name,
        SUM(total_votes) AS total_votes,
        COUNT(movie_id) AS movie_count,        
        ROUND(SUM(avg_rating * total_votes) / SUM(total_votes),2) AS actor_avg_rating
    FROM 
        Indian_actor_summary
    GROUP BY 
        actor_name
    HAVING 
        COUNT(movie_id) >= 5
),
rank_of_actor AS (																				-- Ranking the Indian actors based on average rating and total votes
    SELECT
        actor_name,
        total_votes,
        movie_count,
        actor_avg_rating,
        RANK() OVER w  AS actor_rank
    FROM 
        actor_aggregates
	WINDOW w AS (ORDER BY actor_avg_rating DESC, total_votes DESC)
)
SELECT 																							-- Displaying all the aggregated values for each Inidan actor based on their rank
    actor_name,
    total_votes,
    movie_count,
    actor_avg_rating,
    actor_rank
FROM 
    rank_of_actor
ORDER BY 
    actor_rank;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH Indian_actress_summary AS (																			-- Creating a CTE to house all INDIAN ACTRESS
    SELECT 
        n.name AS actress_name,
        m.id AS movie_id,
        r.avg_rating,
        r.total_votes
    FROM
        names n
		INNER JOIN role_mapping rm ON n.id = rm.name_id
		INNER JOIN ratings r ON r.movie_id = rm.movie_id
        INNER JOIN movie m ON m.id = rm.movie_id
    WHERE 
        rm.category = 'actress'
        AND m.country LIKE '%India%'
        AND m.languages LIKE '%Hindi%'
),
actress_aggregates AS (																					-- Calculating Indian actress details and keeping in a CTE
    SELECT
        actress_name,
        SUM(total_votes) AS total_votes,
        COUNT(movie_id) AS movie_count,        
        ROUND(SUM(avg_rating * total_votes) / SUM(total_votes),2) AS actress_avg_rating
    FROM 
        Indian_actress_summary
    GROUP BY 
        actress_name
    HAVING 
        COUNT(movie_id) >= 3
),
rank_of_actress AS (																					-- Ranking the Indian actress based on average rating and total votes
    SELECT
        actress_name,
        total_votes,
        movie_count,
        actress_avg_rating,
        RANK() OVER w  AS actress_rank
    FROM 
        actress_aggregates
	WINDOW w AS (ORDER BY actress_avg_rating DESC, total_votes DESC)
)
SELECT 																									-- Displaying all the aggregated values for each Inidan actress based on their rank																					
    actress_name,
    total_votes,
    movie_count,
    actress_avg_rating,
    actress_rank
FROM 
    rank_of_actress
ORDER BY 
    actress_rank
LIMIT 5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	
    Note: Sort the output by average ratings (desc).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/

-- Type your code below:

WITH Thriller_movies_Summary AS(														-- Creating a CTE to house all thriller movies with votes more than 25k						
SELECT
	m.title AS movie_name,
    r.avg_rating AS avg_rating
    
FROM
	movie m
    INNER JOIN genre g ON m.id= g.movie_id
    INNER JOIN ratings r USING(movie_id)
WHERE
	g.genre = "Thriller" AND r.total_votes >=25000
)
SELECT
	movie_name,
	CASE 																				-- Categorising movies based on their average ratings	
		WHEN avg_rating > 8 THEN "Superhit"
        WHEN avg_rating > 7 AND avg_rating <= 8 THEN "Hit"
        WHEN avg_rating > 5 AND avg_rating <= 7 THEN "One-time-watch"
        ELSE "Flop"
	END AS movie_category
FROM
	Thriller_movies_Summary
    ORDER BY avg_rating DESC;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH genre_AvgDuration_summary AS														-- Creating a CTE to house average duration of movies, grouped by genre  	
(
SELECT 
	g.genre AS genre,
	AVG(m.duration) AS avg_duration    
FROM
	movie m
	INNER JOIN genre g
    ON g.movie_id = m.id
GROUP BY 
	genre  
)
SELECT *,																				-- Computing running total and running average on movie's duration  	
		ROUND(SUM(avg_duration) OVER w1,2) AS running_total_duration,
        ROUND(AVG(avg_duration) OVER w2,2) AS moving_avg_duration
FROM 
	genre_AvgDuration_summary
WINDOW w1 as (ORDER BY genre ROWS UNBOUNDED PRECEDING),
w2 AS (ORDER BY genre ROWS UNBOUNDED PRECEDING);

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:



WITH Top_three_genre AS(																		-- Top 3 Genres based on most number of movies
SELECT
	g.genre AS genre,
    COUNT(id) AS movie_count
FROM
	genre g 
    INNER JOIN movie m
    ON g.movie_id = m.id
GROUP BY
	genre
ORDER BY movie_count DESC
LIMIT 3
),
casting_gross_income AS(														-- Extracting the numerical substring and then converting the gross income into decimal data type for further arthematic operations 
SELECT
	g.genre,
    m.year,
    m.title AS movie_name,
    CAST(SUBSTR(m.worlwide_gross_income, 2) AS DECIMAL(15, 0)) AS gross_income
FROM
	genre g 
    INNER JOIN movie m
    ON g.movie_id = m.id
WHERE g.genre IN (SELECT genre FROM Top_three_genre)
),
ranking_movies AS (																-- Created genre and year based frames and then ranked movies within these frames based on their gross income 
SELECT
	*,
    RANK() OVER w AS movie_rank
FROM
	casting_gross_income
WINDOW w AS (PARTITION BY genre, year ORDER BY gross_income DESC)
)
SELECT																			-- Prefixed $ infront of gross income. Filtered Top 5 movies based on their rank
	genre,				
    year,
    movie_name,
    CONCAT('$',gross_income) AS worldwide_gross_income,
    movie_rank
FROM
	ranking_movies
WHERE 
	movie_rank <=5
ORDER BY
	genre, year, movie_rank;


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
   
    WITH Multilingual_production_companies AS (								-- Creating CTE to store top rated multilngual movies 
	SELECT 
		production_company, 
		Count(m.id) AS movie_count
	FROM 
		MOVIE AS m
		INNER JOIN RATINGS AS r ON r.movie_id = m.id
    WHERE 
		median_rating >= 8
		AND production_company IS NOT NULL
		AND Position(',' IN languages) > 0									-- Using position function we are only filtering the mutiple languages 
    GROUP BY 
		production_company
    ORDER BY 
		movie_count DESC
) 
    SELECT 																	-- Ranking the movies based on number of mutilingual movies 
		production_company, 
        movie_count,
		RANK() OVER w AS prod_comp_rank 
	FROM 
		Multilingual_production_companies
	WINDOW w AS (ORDER BY movie_count DESC)
	LIMIT 2;    
	

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:

WITH super_hit_drama_movies AS(															-- Creating CTE to store super hit drama movies
SELECT
	m.id AS movie_id
FROM
	movie m
	INNER JOIN ratings r ON m.id = r.movie_id
    INNER JOIN genre g ON m.id = g.movie_id    
WHERE 
	r.avg_rating>8
	AND 
    g.genre = "drama"
),
actress_details AS(																		-- Extracting the actress details from those superhit drama movies
SELECT
	n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes),2) AS actress_avg_rating,	 -- calculates weighted average based on votes
    COUNT(m.id) AS movie_count
FROM
	movie m
	INNER JOIN ratings r ON m.id = r.movie_id
    INNER JOIN role_mapping rm ON rm.movie_id = m.id
    INNER JOIN names n ON n.id = rm.name_id
WHERE
	rm.category ="actress"
    AND
    m.id IN (SELECT movie_id FROM super_hit_drama_movies)
GROUP BY
	actress_name    
),
actress_ranking AS(																			-- Ranking the actress based on weighted avg votes, no. of votes and alphabetically by actress name.
SELECT
	*,
    RANK() OVER w  AS actress_rank 
FROM 
	actress_details
WINDOW w AS(ORDER BY actress_avg_rating DESC, total_votes DESC, actress_name ASC ) 
)
SELECT 																						-- Top three actress based on the number of Super Hit movies in 'drama' genre
	actress_name,
	total_votes,
	movie_count,
    actress_avg_rating,
    actress_rank	
FROM
	actress_ranking
WHERE 
	actress_rank <=3
ORDER BY 
	actress_rank; 



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

    
WITH director_movies AS (																				-- Clubbing all the movies based on director in a CTE
    SELECT
        dm.name_id AS director_id,
        n.name AS director_name,
        m.id AS movie_id,
        m.duration,
        r.avg_rating,
        r.total_votes,
        m.date_published,
        RANK() OVER w AS movie_rank					
    FROM
        movie m
        INNER JOIN ratings r ON m.id = r.movie_id
        INNER JOIN director_mapping dm ON dm.movie_id = m.id
        INNER JOIN names n ON n.id = dm.name_id
		WINDOW w as (PARTITION BY dm.name_id ORDER BY m.date_published)									-- Using partition clause, created frames based on director's id and then ordered by movie publication date
),
inter_movie_duration AS (
    SELECT
       *,
        DATEDIFF(																						-- Retriving date difference between two consecutive movie publication dates
			LEAD(dm.date_published) OVER(
				PARTITION BY dm.director_id ORDER BY dm.date_published), dm.date_published
				)AS inter_movie_days
    FROM
        director_movies dm
),
director_summary AS (																					-- Deploying aggregate functions for top 9 directors based on number of movies 
    SELECT
        director_id,
        director_name,
        COUNT(movie_id) AS number_of_movies,
        AVG(inter_movie_days) AS avg_inter_movie_days,
        AVG(avg_rating) AS avg_rating,
        SUM(total_votes) AS total_votes,
        MIN(avg_rating) AS min_rating,
        MAX(avg_rating) AS max_rating,
        SUM(duration) AS total_duration
    FROM
        inter_movie_duration
    GROUP BY
        director_id, 
        director_name
    ORDER BY
        number_of_movies DESC
    LIMIT 9
)
SELECT																											-- Presenting the output as per requirement. 
    director_id,
    director_name,
    number_of_movies,
    ROUND(avg_inter_movie_days, 2) AS avg_inter_movie_days,
    ROUND(avg_rating, 2) AS avg_rating,
    total_votes,
    ROUND(min_rating, 2) AS min_rating,
    ROUND(max_rating, 2) AS max_rating,
    total_duration
FROM
    director_summary
ORDER BY
    number_of_movies DESC, 
    avg_rating DESC, 
    total_votes DESC, 
    director_name ASC;










