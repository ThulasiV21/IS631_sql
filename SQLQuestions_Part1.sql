--Answer to Question 1
SELECT [playerID], [teamID], [H], [HR], [BB]
FROM [dbo].[Batting];
GO

--Answer to Question 2
SELECT [playerID], [teamID], [H], [HR], [BB]
FROM [dbo].[Batting] ORDER BY [playerID] DESC, [teamID] ASC;
GO

--Answer to Question 3
SELECT DISTINCT [playerID], [teamID]
FROM [dbo].[Batting] ORDER BY [playerID] DESC, [teamID] ASC;
GO

--Answer to Question 4
SELECT [playerID], [yearID], [teamID], ((([B2] * 2) + ([B3] * 3) + ([HR] * 4)) + ([BB] + [H])) AS Total_Bases_Touched
FROM [dbo].[Batting];
GO

--Answer to Question 5
SELECT [playerID], [yearID], [teamID], ((([B2] * 2) + ([B3] * 3) + ([HR] * 4)) + ([BB] + [H])) AS Total_Bases_Touched
FROM [dbo].[Batting]
WHERE [teamID] IN ('NYA', 'NYN');
GO

--Answer to Question 6
SELECT b.[playerID], b.[yearID], b.[teamID], (((b.[B2] * 2) + (b.[B3] * 3) + (b.[HR] * 4)) + (b.[BB] + b.[H])) AS Total_Bases_Touched,
(((t.[B2] * 2) + (t.[B3] * 3) + (t.[HR] * 4)) + (t.[BB] + t.[H])) AS Teams_Bases_Touched,
FORMAT( (((b.[B2] * 2.0) + (b.[B3] * 3.0) + (b.[HR] * 4.0) + (b.[BB] +
b.[H]))/((t.[B2] * 2.0) + (t.[B3] * 3.0) + (t.[HR] * 4.0) + (t.[BB] +
t.[H]))), 'P') AS [Touched_%]
FROM [dbo].[Batting] AS b, [dbo].[Teams] AS t
WHERE b.[teamID] = t.[teamID] AND b.[yearID] = t.[yearID] AND b.[teamID] IN ('NYA', 'NYN');
GO

--Answer to Question 7
SELECT b.[playerID], b.[yearID], b.[teamID], (((b.[B2] * 2) + (b.[B3] * 3) + (b.[HR] * 4)) + (b.[BB] + b.[H])) AS Total_Bases_Touched,
(((t.[B2] * 2) + (t.[B3] * 3) + (t.[HR] * 4)) + (t.[BB] + t.[H])) AS Teams_Bases_Touched,
FORMAT( (((b.[B2] * 2.0) + (b.[B3] * 3.0) + (b.[HR] * 4.0) + (b.[BB] +
b.[H]))/((t.[B2] * 2.0) + (t.[B3] * 3.0) + (t.[HR] * 4.0) + (t.[BB] +
t.[H]))), 'P') AS [Touched_%]
FROM [dbo].[Batting] AS b JOIN [dbo].[Teams] AS t
ON b.[teamID] = t.[teamID] AND b.[yearID] = t.[yearID]
WHERE b.[teamID] IN ('NYA', 'NYN');
GO

--Answer to Question 8
SELECT p.[playerID], p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name], b.[yearID],
Convert(decimal(5,4), (cast(b.[H] as float)* 1/ cast(b.[AB] as float))) AS [Batting Average]
FROM [dbo].[Batting] AS b JOIN [dbo].[People] AS p
ON p.[playerID] = b.[playerID]
WHERE b.[yearID] >= 2000 AND b.[yearID] <= 2020 AND p.[nameFirst] LIKE '%.%' AND b.[teamID] IN ('NYA', 'NYN') AND b.[AB] > 0;
GO

--Answer to Question 9
SELECT p.[playerID], p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name], b.[yearID],
Convert(decimal(5,4), (cast(b.[H] as float)* 1/ cast(b.[AB] as float))) AS [Batting Average]
FROM [dbo].[Batting] AS b JOIN [dbo].[People] AS p
ON p.[playerID] = b.[playerID]
WHERE b.[yearID] >= 2000 AND b.[yearID] <= 2020 
AND p.[nameFirst] LIKE '%.%' 
AND b.[teamID] IN ('NYA', 'NYN') 
AND b.[AB] > 0
AND (cast(b.[H] as float)* 1/ cast(b.[AB] as float)) BETWEEN 0.2 and 0.4999
ORDER BY [Batting Average] DESC, p.[playerID] ASC, b.[yearID] ASC;
GO

--Answer to Question 10
SELECT p.[playerID],
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
b.[yearID],
b.[teamID],
(((b.[B2] * 2) + (b.[B3] * 3) + (b.[HR] * 4)) + (b.[BB] + [H])) AS Total_Bases_Touched,
Convert(decimal(5,4), (cast(b.[H] AS float)* 1/ cast(b.[AB] AS float))) AS [Batting Average],
convert(decimal(5,4),b.h*1.0/b.ab) as [Team_Batting_Average]
FROM [dbo].[People] AS p, [dbo].[Batting] AS b
WHERE p.[playerID] = b.[playerID] 
AND b.[AB] >= 50
AND (cast(b.[H] as float)* 1/ cast(b.[AB] as float)) BETWEEN 0.2 and 0.4999
ORDER BY [Batting Average] DESC, p.[playerID] ASC, b.[yearID] ASC;
GO

-- My version
-- SELECT p.[playerID],
-- p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
-- b.[yearID],
-- b.[teamID],
-- (((b.[B2] * 2) + (b.[B3] * 3) + (b.[HR] * 4)) + (b.[BB] + [H])) AS Total_Bases_Touched,
-- Convert(decimal(5,4), (cast(b.[H] AS float)* 1/ cast(b.[AB] AS float))) AS [Batting Average],
-- c.Team_Batting_Average
-- FROM [dbo].[People] AS p, [dbo].[Batting] AS b,
-- (
--     select [teamID], 
--     sum(Convert(decimal(5,4), cast([H] AS float) * 1/ cast([AB] AS float))) as [Team_Batting_Average] 
--     from Batting 
--     WHERE [AB]>0
--     GROUP BY [teamID]
-- ) AS c
-- WHERE p.[playerID] = b.[playerID] 
-- AND b.[AB] >= 50
-- AND (cast(b.[H] as float)* 1/ cast(b.[AB] as float)) BETWEEN 0.2 and 0.4999
-- AND b.[teamID] = c.[teamID]
-- ORDER BY [Batting Average] DESC, p.[playerID] ASC, b.[yearID] ASC;
-- GO

-- QUERY TO ENABLE CLR OR UPDATE CLR VALUE TO 1 (DOES NOT WORK FOR MAC M1)
-- EXEC sp_configure 'show advanced options', 1;
-- GO
-- RECONFIGURE;
-- GO
-- sp_configure 'clr enabled', 1;
-- GO
-- RECONFIGURE;
-- GO

