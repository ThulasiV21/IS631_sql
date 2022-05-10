-- Quesion 1: Determine the date range of the records in the Temperature table
SELECT MIN(Date_Local) AS [FISRT DATE], MAX(Date_Local) AS [Last Date]
FROM Temperature
GO

-- Question 2: Find the minimum, maximum and average of the average temperature column for each state sorted by state name
BEGIN
BEGIN
DECLARE @inputstring varchar(50)
DECLARE @currentdate varchar(15)
SET @inputstring ='Begin Question 6 before Index Create At - '
SET @currentdate= (select FORMAT(dateadd(hour,-4,GETUTCDATE()), 'hh:mm:ss'))
PRINT @inputstring + convert(VARCHAR,@currentdate,103)
END

-- select FORMAT(dateadd(hour,-4,GETUTCDATE()), 'hh:mm:ss')

-- SELECT  FORMAT(GETDATE() + 4, 'hh:mm:ss')
--       AS 'Current TIME using GETDATE()'

BEGIN
SELECT aqs.State_Name,
CAST(MIN(t.Average_Temp) AS DECIMAL(10,6)) AS [Minimum Temp],
CAST(MAX(t.Average_Temp) AS DECIMAL(10,6)) AS [Maximum Temp],
CAST(AVG(t.Average_Temp) AS DECIMAL(10,6)) AS [Average Temp]
FROM aqs_sites AS aqs INNER JOIN Temperature AS t
ON aqs.State_Code = t.State_Code
GROUP BY aqs.State_Name
ORDER BY aqs.State_Name ASC
END

BEGIN
DECLARE @inputstring1 varchar(50)
DECLARE @currentdate1 varchar(15)
SET @inputstring1 ='Complete Question 6 before Index Create At  - '
SET @currentdate1= (select FORMAT(dateadd(hour,-4,GETUTCDATE()), 'hh:mm:ss'))
PRINT @inputstring1 + convert(VARCHAR,@currentdate1,103)
END
END

-- Begin Question 6 before Index Create At - 05:29:43
-- (54 rows affected)
-- Complete Question 6 before Index Create At  - 05:29:51
-- Total execution time: 00:00:07.315

-- Begin Question 6 before Index Create At - 07:14:31
-- (54 rows affected)
-- Complete Question 6 before Index Create At  - 07:14:39
-- Total execution time: 00:00:07.627

-- Question 3: The results from question #2 show issues with the database.  Obviously, a temperature of -99 degrees 
-- Fahrenheit in Arizona is not an accurate reading as most likely is 135.5 degrees.  Write the queries to 
-- find all suspect temperatures (below -39o and above 105o). Sort your output by State Name and Average Temperature.
SELECT State_Name,
aqs.State_Code,
aqs.County_Code,
aqs.Site_Number,
CAST(Average_Temp AS DECIMAL(10,6)) AS [Average Temp],
Date_Local As [Date Local]
FROM Temperature AS t, aqs_sites AS aqs
WHERE t.State_Code = aqs.State_Code
AND t.County_Code = aqs.County_Code
AND t.Site_Num = aqs.County_Code
AND (Average_Temp <= -39 OR Average_Temp > 105)
ORDER BY aqs.State_Name DESC, [Average Temp] ASC
GO

-- Question 4: You noticed that the average temperatures become questionable below -39 o and above 125 o and that 
-- it is unreasonable to have temperatures over 105 o for state codes 30, 29, 37, 26, 18, 38. You also 
-- decide that you are only interested in living in the United States, not Canada or the US territories. 
-- Create a view that combines the data in the AQS_Sites and Temperature tables. The view should have 
-- the appropriate SQL to exclude the data above. You should use this view for all subsequent queries. 
-- My view returned 5,616,112 rows. The view includes the State_code, State_Name, County_Code, 
-- Site_Number, Make sure you include schema binding in your view for later problems.
IF OBJECT_ID('Weather_View', 'V') IS NOT NULL
    DROP VIEW Weather_View;
GO

CREATE view Weather_View (State_Code, State_Name, County_Code, Site_Number)
WITH SCHEMABINDING
AS
SELECT aqs.State_Code,
aqs.State_Name,
aqs.County_Code,
aqs.Site_Number
FROM [dbo].Temperature t, [dbo].AQS_Sites aqs
WHERE t.State_Code = aqs.State_Code
AND t.Site_Num = aqs.Site_Number
AND t.County_Code = aqs.County_Code
AND t.State_Code NOT IN ('CC', '80', '66', '72', '78')
AND t.Average_Temp >= -39
AND ((t.Average_Temp <= 125) OR (t.Average_Temp <= 105 AND t.State_Code IN ('18', '26', '29', '30', '37', '38')))
GO

-- Checking the row count of each state code in view
SELECT wv.State_Code, COUNT(*)
FROM Weather_View wv
GROUP BY wv.State_Code
ORDER BY wv.State_Code
GO

-- Question 5: Using the SQL RANK statement, rank the states by Average Temperature
BEGIN

BEGIN
DECLARE @inputstring varchar(50)
DECLARE @currentdate varchar(15)
SET @inputstring ='Begin Question 6 before Index Create At - '
SET @currentdate= (select FORMAT(dateadd(hour,-4,GETUTCDATE()), 'hh:mm:ss'))
PRINT @inputstring + convert(VARCHAR,@currentdate,103)
END

SELECT wv.State_Name,
       CAST(Min(average_temp) AS DECIMAL(5, 2)) AS min_temp,
       CAST(Max(average_temp) AS DECIMAL(5, 2)) AS max_temp,
       CAST(Avg(average_temp) AS DECIMAL(10, 6)) AS avg_temp,
       RANK()
         OVER (
             ORDER BY Avg(average_temp) desc) Rank
FROM   temperature t, Weather_View wv
where t.State_Code = wv.State_Code
GROUP BY wv.State_Name

BEGIN
DECLARE @inputstring1 varchar(50)
DECLARE @currentdate1 varchar(15)
SET @inputstring1 ='Complete Question 6 before Index Create At  - '
SET @currentdate1= (SELECT FORMAT(dateadd(hour,-4,GETUTCDATE()), 'hh:mm:ss'))
PRINT @inputstring1 + convert(VARCHAR,@currentdate1,103)
END
END

-- Before Index was created
-- Begin Question 6 before Index Create At - 05:33:02
-- (51 rows affected)
-- Complete Question 6 before Index Create At  - 05:33:32
-- Total execution time: 00:00:30.304

-- After Index was Created
-- Begin Question 6 before Index Create At - 05:36:16
-- (51 rows affected)
-- Complete Question 6 before Index Create At  - 05:36:47
-- Total execution time: 00:00:30.985

-- Question 6: Create an index for your view. You are required to create a single  index with the unique and clustered parameters and the index will be on 
-- the State_Code, County_Code, Site_Number, Date_Local columns. DO NOT create the index on the 
-- tables, the index must be created on the VIEW.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[Weather_View]
WITH SCHEMABINDING
AS
SELECT aqs.State_Code,
aqs.State_Name,
aqs.County_Code,
aqs.Site_Number,
CAST(t.Date_Local AS VARCHAR(20) ) AS Date_Local
FROM [dbo].Temperature t, [dbo].AQS_Sites aqs
WHERE t.State_Code = aqs.State_Code
AND t.Site_Num = aqs.Site_Number
AND t.County_Code = aqs.County_Code
AND t.State_Code NOT IN ('CC', '80', '66', '72', '78')
AND t.Average_Temp >= -39
AND ((t.Average_Temp <= 125) OR (t.Average_Temp <= 105 AND t.State_Code IN ('18', '26', '29', '30', '37', '38')))
GO

-- Checking if duplicate rows exist in Temperature Table
SELECT * from (
SELECT state_code,
       county_code,
       site_num,
       date_local,
       Row_number()
         OVER (
           PARTITION BY state_code, county_code, site_num,
         date_local
           ORDER BY state_code, county_code, site_num, date_local)
       AS
       row_numb
FROM   Temperature
) AS X WHERE X.row_numb > 1
GO

-- Checking if duplicate rows exist in aqs_sites Table --> No dups in aqs_sites table
SELECT * from (
SELECT state_code,
       county_code,
       Site_Number,
       Row_number()
         OVER (
           PARTITION BY state_code, county_code, Site_Number
           ORDER BY state_code, county_code, Site_Number)
       AS
       row_numb
FROM   AQS_Sites
) AS X WHERE X.row_numb > 1
GO

-- Deleting duplicate rows from Temperature Table
WITH t
     AS (SELECT state_code,
       county_code,
       site_num,
       date_local,
       Row_number()
         OVER (
           PARTITION BY state_code, county_code, site_num,
         date_local
           ORDER BY state_code, county_code, site_num, date_local)
       AS
       row_numb
FROM   Temperature)
DELETE FROM t
WHERE  row_numb > 1
GO

-- Changed the data type of Date_Local to varcahr(20) because of the below issue while creating the index.
-- "Column 'Date_Local' in table 'Weather_View' is of a type that is invalid for use as a key column in an index."


-- Creating clustered unique index
IF OBJECT_ID('IDX_Weather_View', 'I') IS NOT NULL
    DROP VIEW IDX_Weather_View;
GO

CREATE UNIQUE CLUSTERED INDEX
IDX_Weather_View
ON Weather_View(State_Code, County_Code, Site_Number, Date_Local)
GO

SET STATISTICS IO ON
GO
SELECT * FROM Weather_View
GO

-- Question 7: You’ve decided that you want to see the ranking of each high temperatures for each city in each state 
-- to see if that helps you decide where to live. Write a query that ranks (using the rank function) the 
-- states by averages temperature and then ranks the cities in each state. The ranking of the cities should 
-- restart at 1 when the query returns a new state. You also want to only show results for the 15 states 
-- with the highest average temperatures.

SELECT A.State_Rank, A.State_Name, B.City_Rank, B.City_Name, B.Average_Temperature
FROM
(SELECT avg(t.Average_Temp) as temp, A.State_Name,
    RANK() OVER (ORDER BY avg(t.Average_Temp) DESC) AS State_Rank FROM Temperature t,
    (SELECT DISTINCT state_name, State_Code FROM Weather_View) A
    WHERE t.State_Code=A.State_Code
    GROUP BY A.State_Name) A,
(
SELECT aqs.State_Name, aqs.City_Name, CAST(AVG(t.Average_Temp) AS DECIMAL(10, 6)) AS Average_Temperature,
DENSE_RANK() OVER (PARTITION BY aqs.State_Name ORDER BY avg(t.Average_Temp) DESC) AS City_Rank FROM Temperature t, AQS_Sites aqs
WHERE t.State_Code = aqs.State_Code
AND t.Site_Num = aqs.Site_Number
GROUP BY aqs.City_Name, aqs.State_Name
) B
WHERE A.State_Name = B.State_Name
AND A.State_Rank <= 15
ORDER BY A.State_Rank, B.City_Rank
GO

-- Question 8: You notice in the results that sites with Not in a City as the City Name are include but do not provide 
-- you useful information. Exclude these sites from all future answers. You can do this by either adding it 
-- to the where clause in the remaining queries or updating the view you created in #4
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[Weather_View]
WITH SCHEMABINDING
AS
SELECT aqs.State_Code,
aqs.State_Name,
aqs.County_Code,
aqs.Site_Number,
aqs.City_Name,
CAST(t.Date_Local AS VARCHAR(20) ) AS Date_Local
FROM [dbo].Temperature t, [dbo].AQS_Sites aqs
WHERE t.State_Code = aqs.State_Code
AND t.Site_Num = aqs.Site_Number
AND t.County_Code = aqs.County_Code
AND t.State_Code NOT IN ('CC', '80', '66', '72', '78')
AND t.Average_Temp >= -39
AND ((t.Average_Temp <= 125) OR (t.Average_Temp <= 105 AND t.State_Code IN ('18', '26', '29', '30', '37', '38')))
AND aqs.City_Name != 'Not in a City'
GO

-- Checking if the city name is present or not
SELECT DISTINCT city_name FROM Weather_View WHERE City_Name='Not in a City'
GO

-- Question 9: You’ve decided that the results in #8 provided too much information and you only want to 3 cities with 
-- the highest temperatures and group the results by state rank then city rank.
SELECT B.State_Rank, B.State_Name, C.City_Rank, C.City_Name, C.Average_Temperature
FROM
(SELECT avg(t.Average_Temp) as temp, A.State_Name,
    RANK() OVER (ORDER BY avg(t.Average_Temp) DESC) AS State_Rank FROM Temperature t,
    (SELECT DISTINCT state_name, State_Code FROM Weather_View) A
    WHERE t.State_Code=A.State_Code
    GROUP BY A.State_Name) B,
(
SELECT wv.State_Name, wv.City_Name, CAST(AVG(t.Average_Temp) AS DECIMAL(10, 6)) AS Average_Temperature,
DENSE_RANK() OVER (PARTITION BY wv.State_Name ORDER BY avg(t.Average_Temp) DESC) AS City_Rank FROM Temperature t, Weather_View wv
WHERE t.State_Code = wv.State_Code
AND t.Site_Num = wv.Site_Number
GROUP BY wv.City_Name, wv.State_Name
) C
WHERE B.State_Name = C.State_Name
AND B.State_Rank <= 15
AND C.City_Rank <= 3
ORDER BY B.State_Rank, C.City_Rank 
GO

-- Question 10: You decide you like the average temperature to be in the 80's. Pick 3 cities that meets this condition 
-- and calculate the average temperature by month for those 3 cities. You also decide to include a count 
-- of the number of records for each of the cities to make sure your comparisons are being made with 
-- comparable data for each city.
SELECT wv.City_Name, CAST(AVG(t.Average_Temp) AS DECIMAL(10, 6)) AS Average_Temperature
FROM Temperature t, Weather_View wv
WHERE t.State_Code = wv.State_Code
AND t.Site_Num = wv.Site_Number
GROUP BY wv.City_Name
HAVING AVG(Average_Temp) >= 80
GO
-- Picking the above 3 cities for the below query

SELECT wv.City_Name, DATEPART(month, wv.Date_Local) [Month], COUNT(t.Average_Temp) AS [# of Rows], AVG(t.Average_Temp) AS [Average Temperature] 
FROM Weather_View wv, Temperature t
WHERE wv.State_Code = t.State_Code
AND wv.Site_Number = t.Site_Num
GROUP BY DATEPART(month, wv.Date_Local), wv.City_Name
HAVING AVG(Average_Temp) >= 80
ORDER BY [Month]
GO

-- Question 11: You assume that the temperatures follow a normal distribution and that the majority of the temperatures 
-- will fall within the 40% to 60% range of the cumulative distribution. Using the CUME_DIST function, 
-- show the temperatures for the same 3 cities that fall within the range.

WITH Distribution_List AS
(
SELECT wv.City_Name, CAST(t.Average_Temp AS DECIMAL(10, 6)) AS [Average Temp],
  CAST(CUME_DIST() OVER (ORDER BY t.Average_Temp DESC) AS DECIMAL(8, 6)) AS Temp_Cume_Dist
  FROM Weather_View wv, Temperature t
  WHERE wv.State_Code = t.State_Code
  AND wv.Site_Number = t.Site_Num
  AND wv.City_Name IN ('Springerville', 'Boron', 'Ludlow')
  GROUP BY wv.City_Name, t.Average_Temp
  )
SELECT * FROM Distribution_List
WHERE Temp_Cume_Dist >= 0.40 AND Temp_Cume_Dist <= 0.60

-- Question 12: You decide this is helpful, but too much information. You decide to write a query that shows the first 
-- temperature and the last temperature that fall within the 40% and 60% range for the 3 cities your 
-- focusing on.

WITH Distribution_List_40 AS
(
SELECT wv.City_Name, CAST(t.Average_Temp AS DECIMAL(10, 6)) AS [Average Temp],
  CAST(CUME_DIST() OVER (ORDER BY t.Average_Temp DESC) AS DECIMAL(8, 6)) AS Temp_Cume_Dist
  FROM Weather_View wv, Temperature t
  WHERE wv.State_Code = t.State_Code
  AND wv.Site_Number = t.Site_Num
  AND wv.City_Name IN ('Springerville', 'Boron', 'Ludlow')
  GROUP BY wv.City_Name, t.Average_Temp
  )
SELECT * FROM Distribution_List_40
WHERE Temp_Cume_Dist >= 0.40 AND Temp_Cume_Dist <= 0.60

SELECT wv.City_Name,
PERCENTILE_DISC(0.4) WITHIN GROUP (ORDER BY t.Average_Temp) OVER (PARTITION BY wv.City_Name) AS [40 Percentile Temp],
PERCENTILE_DISC(0.6) WITHIN GROUP (ORDER BY t.Average_Temp) OVER (PARTITION BY wv.City_Name) AS [60 Percentile Temp]
FROM Weather_View wv, Temperature t
WHERE wv.State_Code = t.State_Code
-- AND wv.Site_Number = t.Site_Num
-- AND wv.City_Name IN ('Springerville', 'Boron', 'Ludlow')

SELECT DISTINCT wv.City_Name, PERCENTILE_DISC(0.4) WITHIN GROUP (ORDER BY t.AVERAGE_TEMP) OVER (PARTITION BY wv.CITY_NAME) AS '40 PERCENTILE TEMP', 
PERCENTILE_DISC(0.6) WITHIN GROUP (ORDER BY t.AVERAGE_TEMP) OVER (PARTITION BY wv.CITY_NAME) AS '60 PERCENTILE TEMP'
FROM Temperature t, Weather_View wv
WHERE wv.State_Code = t.State_Code
-- AND wv.City_Name IN ('Springerville Park', 'Boron', 'Ludlow')
ORDER BY City_Name

