SELECT TOP (1000) [airport_code]
      ,[airport_name]
      ,[airport_city]
      ,[airport_state]
  FROM [CleaningData1].[dbo].[airports]


--**Cleaning Table on Airports**:

SELECT*
FROM airports
-------------------------------
--1)✅ airport code clean 
SELECT airport_code
FROM airports
-------------------------------
--2) airport_name : Problem(Formatting issues:inconsistent Formatting)
-- We realize that some values of the airport_name column are messy strings. 
--These strings have leading and trailing spaces.
SELECT TRIM(airport_name) AS Edited_Airport_Name
FROM airports
-------------------------------
--3) airport_city,airport_state : Problem(fl,ch,nyc)(Textual Data Issues,Ambiguity)
SELECT airport_city,airport_state
FROM airports
WHERE airport_city IN ('ch','nyc') OR airport_state IN ('fl','Fl','FL')
--*******************--
-- 1. One easy solution is to concatenate two REPLACE functions.
-- Unifying strings - 2 REPLACEs
SELECT airport_code, airport_name, airport_city,  
REPLACE(REPLACE(airport_state, 'FL', 'Florida'), 'Floridaorida', 'Florida') AS airport_state
FROM airports
ORDER BY airport_state;
/* 2. Another solution can be applying the CASE statement.
      We can order to replace the values of the column airport_state when these values are different than "Florida".
      In other cases, we can leave the string as it is.
*/
-- Unifying strings - REPLACE + CASE
SELECT airport_code, airport_name, airport_city,  
    CASE 
        WHEN airport_state <> 'Florida' THEN REPLACE(airport_state, 'FL', 'Florida')
		ELSE airport_state  
    END AS airport_state 
FROM airports 


--3.
SELECT airport_code, airport_name, 
	CASE
    	-- Unify the values
		WHEN airport_city <> 'Chicago' 
		THEN Replace(airport_city, 'ch', 'Chicago')
		ELSE airport_city 
	END AS airport_city,
    airport_state
FROM airports
WHERE airport_code IN ('ORD', 'MDW')
--4.
SELECT airport_code, airport_name, 
	CASE
    	-- Unify the values
		WHEN airport_city <> 'New York' 
		THEN Replace(airport_city, 'nyc', 'New York')
		ELSE airport_city 
	END AS airport_city,
    airport_state
FROM airports
--**************--
--4) airport_city,airport_state : Problem(NULL Values)
-- To check if the value is NULL:
-- For the airport_state column, we can do it by using IS NULL.
SELECT * 
FROM airports 
WHERE airport_state IS NULL 
-- We can substitute NULL values using the ISNULL function.
--ISNULL replaces the NULL value with a specified value.
SELECT airport_code, airport_city, airport_state, 
COALESCE (airport_state, airport_city, 'Unknown') AS airport_state_fixed 
FROM airports 

SELECT airport_code, airport_city, airport_state, 
COALESCE (airport_city, airport_state, 'Unknown') AS airport_city_fixed 
FROM airports 
-- Let's see how to remove the rows from the airports table that have NULL values for the airport_state column.
DELETE FROM airports
WHERE airport_state IS NULL;

-----------------------------------------------------------------------------------------------------
--**Cleaning Table on carriers**:
SELECT*
FROM carriers
-- Some words that are stored in the name column have extra leading and trailing spaces.

SELECT TRIM(name) AS trimmed_name
FROM carriers;
-----------------------------------------------------------------------------------------------------
--**Cleaning Table on clients , clients split after joining them(NULL values)** : 
SELECT C.client_id,C.client_name+' '+C.client_surname AS Full_Name,
C.city,C.state,CS.city_state
FROM clients C
JOIN clients_split CS
ON C.client_id=CS.client_id

-- We can substitute NULL values using the ISNULL function.
--ISNULL replaces the NULL value with a specified value.
SELECT client_id,city,state,
COALESCE (state, city, 'Unknown') AS state_fixed 
FROM clients 
------------------------------------

--**Cleaning Table on episodes:(cleaned)**
SELECT*
FROM episodes


--**Cleaning Table on vendors:(cleaned)**
SELECT*
FROM vendors
------------------------------------------
--**Cleaning Table on paper_shop_daiy_sales ,paper_shop_monthly_sales :(cleaned)**
SELECT *
FROM paper_shop_monthly_sales
SELECT*
FROM paper_shop_daily_sales
--------------------------------------------
--**Cleaning Table on series:**
SELECT *
FROM series

-- in_ratings (10اخره من  ) , any person more than 10 , i will make it 10

SELECT rating=10,name
FROM series
WHERE rating>10

UPDATE series
SET rating=10
WHERE rating>10

-- in num_rating(value -1)
--بدل -1  هديله avg num rating(MEAN)
SELECT
num_ratings = (SELECT AVG(num_ratings) FROM series WHERE num_ratings>0)
,name
FROM series
WHERE num_ratings<0

UPDATE series
SET num_ratings=(SELECT AVG(num_ratings) FROM series WHERE num_ratings>0)
WHERE num_ratings<0



--official site www.
--update wwq. , www.
--update ww. , www.
SELECT name,official_site,
 REPLACE(REPLACE(official_site,'wwq.','www.') ,'ww.','www.')
FROM series
WHERE name='Dexter'

UPDATE series
SET  official_site=REPLACE(REPLACE(official_site,'wwq.','www.') ,'ww.','www.')
WHERE name='Dexter'

UPDATE series
SET  official_site=REPLACE(official_site,'wwq.','www.') 

--official site in black mirror (ارقام)
--
UPDATE series
SET  official_site=REPLACE(official_site,'www.netflix.com/title/70264888','www.netflix.com/title/Black_Mirror') 

--is adult , minimum age (CONSIDER adult from 16 years old)
SELECT is_adult,min_age
FROM series

UPDATE series
SET is_adult=0
WHERE min_age<16


UPDATE series
SET is_adult=1
WHERE min_age>=16

--contact number (Game of thrones), any thing start with 000
SELECT contact_number
FROM series
WHERE name='Game of Thrones' OR contact_number LIKE '000%'

UPDATE series
SET contact_number = NULL
WHERE name='Game of Thrones' OR contact_number LIKE '000%'
------------------
--**Cleaning Table on pilots:**
SELECT *
FROM pilots
-- If we want to modify the entry_date with another format, we will need to use the CONVERT or the FORMAT functions.
-- 1. Using CONVERT
SELECT pilot_code, pilot_name, pilot_surname, carrier_code,
       CONVERT(VARCHAR, entry_date, 110) AS formatted_date
FROM pilots;

-- 2. Using FORMAT
-- The FORMAT function provides more flexibility but might be slower for large datasets.
SELECT pilot_code, pilot_name, pilot_surname, carrier_code,
       FORMAT(entry_date, 'dd/MM/yyyy') AS formatted_date
FROM pilots;
-------------------------------
--**Cleaning Table on flight statistics:**
-- Detecting duplicate data - ROW_NUMBER()
-- Partitions = repeating groups.
-- Returns a number starting at 1 for the first row in every partition.
-- Returns sequential number for each row within the same partition.
SELECT *, 
       ROW_NUMBER() OVER ( 
            PARTITION BY  
                airport_code,  
                carrier_code,  
                registration_date 
            ORDER BY  
                airport_code,  
                carrier_code,  
                registration_date 
        )AS row_num 
FROM flight_statistics 
ORDER BY
airport_code, carrier_code,  registration_date 
/*
As we can see here the first row receives the number 1,
and the second row within the same partition receives the sequential number 2. 
*/

/*
** If we want to get only the duplicate rows in our results,
   --> we will need to select those rows that have row_num greater than 1.
** However, if we want to exclude duplicate rows,
   --> we will filter those rows with row_num equals to 1. or we can use SELECT DISTINCT
*/

-- Getting only duplicate rows
-- We can include the previous query in a WITH clause, and then select only the rows with a row_num greater than 1.
 WITH cte AS ( 
    SELECT *,  
        ROW_NUMBER() OVER ( 
            PARTITION BY  
                airport_code,  
                carrier_code,  
                registration_date 
            ORDER BY  
                airport_code,  
                carrier_code,  
                registration_date 
        ) row_num 
    FROM flight_statistics 
) 
SELECT * FROM cte 
WHERE row_num > 1; 
-- These are all the duplicate rows that have been detected. As we can see, all of them have a row_num greater than 1.

-- Another solution using GROUP BY & HAVING
SELECT 
    airport_code, 
    carrier_code, 
    registration_date, 
    COUNT(*) AS duplicate_count
FROM flight_statistics
GROUP BY 
    airport_code, 
    carrier_code, 
    registration_date
HAVING COUNT(*) > 1;



-- To exclude the duplicate rows, we can also include the same query in a WITH clause, and then select the rows with a row_num equals to 1.
-- OR
-- We can use SELECT DISTINCT
WITH cte AS ( 
    SELECT *,  
        ROW_NUMBER() OVER ( 
            PARTITION BY  
                airport_code,  
                carrier_code,  
                registration_date 
            ORDER BY  
                airport_code,  
                carrier_code,  
                registration_date 
        ) row_num 
    FROM flight_statistics 
) 
SELECT * FROM cte 
WHERE row_num = 1;
-- As we can see, all the rows have a row_num equals to 1.
-----
SELECT DISTINCT 
    airport_code, 
    carrier_code, 
    registration_date
FROM flight_statistics;
-- If we only need to extract the data without duplicates, but this solution assumes that we don’t need other columns from the table,
-- unlike ROW_NUMBER, as it returns the details of each duplicate row.
