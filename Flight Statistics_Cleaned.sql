-- Messy strings can be a problem because sometimes, it is not easy to analyze them without cleaning them.
-- We will start solving simple problems such as filling numbers with leading zeros, removing trailing or leading spaces in strings, & unifying strings. 

SELECT *
FROM flight_statistics

/*
After exploring the content of the flight_statistics table,
we can see that we have different formats for the registrations codes.
Some of the registration codes have leading zeros, but some of them don't.

Let's suppose that a valid registration code should have leading zeros until complete nine digits.
In those registration codes without leading zeros, we will have to add as many zeros as we need.
In our example, the string we need to replicate is the 0 value,
and the number of times can vary depending on the length of every registration_code.
As valid codes must have nine characters.
Let's solve this problem in two different ways:
1. Using the REPLICATE function that repeats a given string a specified number of times-> REPLICATE (string, integer)
2. Using FORMAT function that formats a value according to a specified format string
*/

-- 1. Filling numbers with leading zeros - Using REPLICATE,LEN
-- * (+) operator
SELECT REPLICATE('0', 9 - LEN(registration_code)) + registration_code AS registration_code 
FROM flight_statistics; 

-- 2. Filling numbers with leading zeros - Using REPLICATE,LEN
-- ** CONCAT
SELECT CONCAT (REPLICATE('0', 9 - LEN(registration_code)), registration_code) AS registration_code 
FROM flight_statistics; 

-- 2. Filling numbers with leading zeros - Using FORMAT
SELECT FORMAT(CAST(registration_code AS INT), '000000000') AS registration_code 
FROM flight_statistics; 

/*
-- '######000' keeps up to 6 digits from the original number and appends zeros at the end if needed.
-- This is not suitable if you want a fixed 9-digit code with leading zeros,
-- because it may pad with zeros at the end instead of the beginning.
*/
--SELECT FORMAT(CAST(registration_code AS INT), '######000') AS registration_code 
--FROM flight_statistics;

-- Update registration_code to be 9 digits by padding with leading zeros
-- Only update rows where the length is less than 9
UPDATE flight_statistics
SET registration_code = REPLICATE('0', 9 - LEN(registration_code)) + registration_code
WHERE LEN(registration_code) < 9;

-- Update registration_code using FORMAT after converting to INT
-- Make sure values are numeric to avoid errors
UPDATE flight_statistics
SET registration_code = FORMAT(CAST(registration_code AS INT), '000000000')
WHERE ISNUMERIC(registration_code) = 1 AND LEN(registration_code) < 9;

-- Add a new column to store the cleaned registration code
ALTER TABLE flight_statistics ADD registration_code_fixed VARCHAR(9);

-- Populate the new column with formatted values
UPDATE flight_statistics
SET registration_code_fixed = REPLICATE('0', 9 - LEN(registration_code)) + registration_code
WHERE LEN(registration_code) < 9;

 
/*
We need to get every register with more than 100 delays from the flight_statistics table. 
In a unique column, we have to concatenate the carrier_code, registration_code, and airport_code, having a similar format to this one:
"AA - 000000119, JFK".
*/
-- 1. Using Replicate
SELECT CONCAT(carrier_code, ' - ', 
              REPLICATE('0', 9 - LEN(registration_code)), 
			  registration_code, ', ', airport_code) AS registration_code
FROM flight_statistics
-- Filter registers with more than 100 delays
WHERE delayed > 100

-- 2. Using Format
SELECT Concat(carrier_code, ' - ', 
		      Format(cast(registration_code AS INT), '0000000'),
		             ', ', airport_code) AS registration_code
FROM flight_statistics
WHERE delayed > 100

----------------------------------------------------------------------------------------------------
-- Let's analyze the content of the carriers table
SELECT *
FROM carriers
-- Some words that are stored in the name column have extra leading and trailing spaces.

/*
To remove leading and trailing spaces we can use the TRIM function.
TRIM removes any specified character from the start and end of a string.
If we don't specify any character, TRIM will remove the space character.
*/

SELECT TRIM(name) AS trimmed_name
FROM carriers;

/*
In case you are working with older versions than SQL Server 2017, the TRIM function won't be available.
So, you can substitute it by using RTRIM and LTRIM.
RTRIM(Right) removes all trailing spaces, whereas LTRIM(left) removes all leading spaces.
If we combine LTRIM with RTRIM, we will get the same output as we got using TRIM.
*/
--Removing additional spaces - RTRIM and LTRIM
-- For older versions than SQL Server 2017 -> 
SELECT code, LTRIM(RTRIM(name)) AS name           
FROM carriers;

-- To apply the changes permanently to the values in the column by removing extra spaces, you can use the TRIM function.
UPDATE carriers
SET name = TRIM(name);

------------------------------------------------------------------------------------------------------
-- Let's analyze the content of the airports table
SELECT *
FROM airports;

-- 1. We realize that some values of the airport_name column are messy strings. These strings have leading and trailing spaces.
UPDATE airports
SET airport_name = TRIM(airport_name);

/*
 -- 2. We can see that in the airport_state column, we have different values for the state of Florida.
	   All of these values are valid, but it is not reasonable to have different values for the same state.
	   Let's see how to unify these different strings.
*/

-- Unifying strings - Using REPLACE Function -> REPLACE replaces all occurrences of a specified string with another string. 
-- The first step we can take is replacing the string "FL" with the string "Florida".
 -- "Fl" / " " / "Florida" -> "Florida"
SELECT  
airport_code, airport_name, airport_city,  
REPLACE(airport_state, 'FL', 'Florida') AS airport_state 
FROM airports 
ORDER BY airport_state;
/*
After executing this code, we can see that the string "Florida" correctly replaced the strings "fl" in lower case letters and "FL" in capital letters.
But, what happened with the last value? The letters "Fl" in the string "Florida" were also replaced by the word "Florida" itself, so we got "Floridaorida" as a result.
Let's fix it.
*/

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
ORDER BY airport_state;

/*
Finally, let's see how to solve this problem if we had chosen to unify these different strings into the "FL" string.
The first step we can take is replacing the string "Florida" with the string "FL", 
*/
 -- "Fl" / " " / "Florida" -> "FL"
SELECT  airport_code, airport_name, airport_city,  
REPLACE(airport_state, 'Florida', 'FL')  AS airport_state
FROM airports 
ORDER BY airport_state

-- But this won't be enough because we still have the string fl in small letters
-- To solve it, we can use the UPPER function. UPPER converts a given string to uppercase. 
-- Unifying strings - REPLACE + UPPER
SELECT airport_code, airport_name, airport_city,  
UPPER( REPLACE(airport_state, 'Florida', 'FL') ) AS airport_state 
FROM airports 
ORDER BY airport_state 

-- last way using like :
-- View all airport_state values that start with "fl" (case-insensitive)
SELECT DISTINCT airport_state
FROM airports
WHERE LOWER(airport_state) LIKE 'fl%';

-- Safe to proceed with update using LIKE:
-- Since the only existing values in the airport_state column that start with "fl" 
-- are "FL" and "Florida", it's safe to use an UPDATE statement with a LIKE 'fl%' condition.
-- This ensures that no unrelated values will be unintentionally modified.
UPDATE airports
SET airport_state = 'Florida'
WHERE LOWER(airport_state) LIKE 'fl%'
  AND airport_state <> 'Florida';


/*
3. There are inconsistent values for 'Chicago' in the airport_city column, with values such as 'ch'.
   We will treat these inconsistent values by replacing them.
*/
SELECT airport_code,airport_name,airport_state,
Replace(airport_city, 'ch', 'Chicago') AS airport_city
FROM airports  
WHERE airport_code IN ('ORD', 'MDW')

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

SELECT 
	airport_code, airport_name,
    	-- Convert to uppercase
    	upper(
            -- Replace 'Chicago' with 'ch'.
          	REPLACE(airport_city, 'Chicago', 'ch')
        ) AS airport_city,
    airport_state
FROM airports
WHERE airport_code IN ('ORD', 'MDW')
--------------------------------------------------------------------------------
SELECT * 
FROM airports
SELECT *
FROM flight_statistics

/*
Missing data can happen for some reason.
Sometimes, it can happen intentionally.
For example, a person who doesn't want to reveal the age, or a person who doesn't know the answer to a question.
In other cases, an error could have occurred when inserting the data.
And finally, sometimes the data simply doesn't exist.
For example, the number of children of a person that doesn't have any children.
*/

-- To select the values that aren't NULL:
-- For the airport_state column, we can do it by using IS NOT NULL.

SELECT * 
FROM airports 
WHERE airport_state IS NOT NULL

-- To check if the value is NULL:
-- For the airport_state column, we can do it by using IS NULL.
SELECT * 
FROM airports 
WHERE airport_state IS NULL 

-- We can substitute NULL values using the ISNULL function. ISNULL replaces the NULL value with a specified value.
-------------------------- ISNULL <> IS NULL--------------------------
SELECT  airport_code,  airport_name,  airport_city,  
ISNULL(airport_state, 'Unknown') AS airport_state 
FROM airports 

--  Fill with numeric value like (Average) - ISNULL with AVG To Replace NULL with the average.
SELECT registration_code, airport_code, carrier_code, 
ISNULL(canceled, (SELECT AVG(canceled) FROM flight_statistics)) AS canceled_fixed 
FROM flight_statistics 
GROUP BY registration_code, airport_code, carrier_code, canceled

-- Fill with other value - COALESCE
SELECT  
airport_code, airport_city, airport_state 
FROM airports 

SELECT airport_code, airport_city, airport_state, 
COALESCE (airport_state, airport_city, 'Unknown') AS airport_state_fixed 
FROM airports 

-- Let's see how to remove the rows from the airports table that have NULL values for the airport_state column.
DELETE FROM airports
WHERE airport_state IS NULL;

-- Checks if the airport_city column has an empty string ('') instead of NULL.
-- It's useful when missing data is represented as an empty string rather than a NULL value.
SELECT *
FROM airports
WHERE airport_city = ''

-- This query excludes rows where airport_city is an empty string (''). 
-- It retrieves rows where airport_city has any non-empty value, including NULLs.
SELECT *
FROM airports
WHERE airport_city <> ''

-- Counts how many rows have an empty string ('') in the airport_state column.
SELECT COUNT(*) AS empty_count
FROM airports
WHERE airport_state = '';

------------------------------------------------------------------------------------------------------------------
--  Duplicate data can interfere in our analysis, so it is essential to identify it.
SELECT *
FROM flight_statistics
/*
For the flight_statistics table,
1. The first thing we can do is exclude rows that are completely duplicated and have the same values in all columns
   like the last 3 rows 23,24 and 25 and other rows are completly duplicated.

2. The second step is to exclude rows that are duplicates across all columns,
   even if they have a different registration_code or statistical name.
   This is because the core information remains the same, so we should keep only one row.
   --> This is based on the fact that the columns forming a duplicate group are:
       airport_code, carrier_code, and registration_date.
       The reason is that flight statistics for a specific airport and carrier are recorded only once per month.
	   Therefore, duplication has no meaning or value in the data.

3. But, if we have the same airport_code, carrier_code, and registration_date and the data of the columns canceled, on_time, delayed, or diverted are different.
   So we have a problem here! because we don't know Which one should we maintain?
   If we find this kind of duplicates, we will need to investigate which one is correct.
*/

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

-----------------------------------------------------
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







