-- Question 1: Provide the SQL to create the geospatial column and populate it as the first part of your answer
-- Updating AQS_Sites Table by creating the GeoLocation Column if not null and populating the column with values
IF COL_LENGTH('AQS_Sites', 'GeoLocation') IS NULL
BEGIN
    ALTER TABLE [dbo].[AQS_Sites] ADD GeoLocation GEOGRAPHY
END

UPDATE [dbo].[AQS_Sites]
SET [GeoLocation] = GEOGRAPHY::STPointFromText('POINT(' + CAST([Longitude] AS VARCHAR(20)) + ' ' + CAST([Latitude] AS VARCHAR(20)) + ')', 4326)
WHERE [Latitude] IS NOT NULL

-- select TOP 10 * from AQS_Sites
-- Question 2: The second requirement for Part 4 is to create the stored procedure and execute the stored procedure for from a spreadsheet
-- Checking if the procedure exists and if not creating a stored procedure
IF EXISTS (
        SELECT 1
        FROM sys.procedures
        WHERE NAME = 'tt347_Summer2019_Calc_GEO_Distance'
        )
BEGIN
    DROP PROCEDURE [dbo].tt347_Summer2019_Calc_GEO_Distance
END
GO

CREATE PROCEDURE tt347_Summer2019_Calc_GEO_Distance @latitude VARCHAR(50)
    , @longitude VARCHAR(50)
    , @State VARCHAR(50)
    , @rownum INT
AS
BEGIN
    DECLARE @h GEOGRAPHY

    SET @h = GEOGRAPHY::Point(@latitude, @longitude, 4326)

    SELECT TOP (@rownum) Site_Number
        , Local_Site_Name = CASE 
            WHEN Local_Site_Name IS NULL
                THEN (CAST(Site_Number AS VARCHAR(10)) + ' ' + City_Name)
            WHEN Local_Site_Name = ''
                THEN (CAST(Site_Number AS VARCHAR(10)) + ' ' + City_Name)
            WHEN Local_Site_Name = '????'
                THEN (CAST(Site_Number AS VARCHAR(10)) + ' ' + City_Name)
            WHEN Local_Site_Name = '___________NO INFORMATION AT THIS TIME'
                THEN (CAST(Site_Number AS VARCHAR(10)) + ' ' + City_Name)
            ELSE Local_Site_Name
            END
        , Address
        , City_Name
        , State_Name
        , Zip_Code
        , Geolocation.STDistance(@h) AS Distance_In_Meters
        , Latitude
        , Longitude
        , (Geolocation.STDistance(@h)) / 80000 AS Hours_of_Travel
    FROM AQS_Sites
    WHERE State_Name = @State
END

-- Execution queries to execuet the stored procedure
EXEC tt347_Summer2019_Calc_GEO_Distance @latitude = '31.968599'
    , @longitude = '-99.901813'
    , @State = 'Texas'
    , @rownum = 20
GO

EXEC tt347_Summer2019_Calc_GEO_Distance @latitude = '-74.005973'
    , @longitude = '40.712775'
    , @State = 'New York'
    , @rownum = 20
GO

SELECT TOP 50 GeoLocation
FROM aqs_sites;
    -- SELECT DISTInct Local_Site_Name from AQS_Sites where Local_Site_Name = '___________NO INFORMATION AT THIS TIME'
    -- select DISTINCT State_Name from AQS_Sites 
    -- WHERE State_Name='Texas'
