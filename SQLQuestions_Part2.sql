--Answer to Question 1
SELECT p.playerid, 
p.birthCity, 
p.birthState,
b.yearID, 
FORMAT(s.salary, 'C') AS Salary,
CONVERT(decimal(5,4), (b.H * 1.0/ NULLIF(b.AB,0))) AS [Batting Average]
FROM People As p, Batting AS b, Salaries AS s
WHERE p.playerID = s.playerID
AND p.playerID = b.playerID
AND s.playerID = b.playerID
AND s.teamID = b.teamID
AND s.yearID = b.yearID
AND p.birthState = 'NJ'
AND b.AB > 0
ORDER BY p.nameLast, s.yearID;
GO

--Answer to Question 2
SELECT p.playerid, 
p.birthCity, 
p.birthState,
b.yearID, 
FORMAT(s.salary, 'C') AS Salary,
CONVERT(decimal(5,4), (b.H * 1.0/ NULLIF(b.AB,0))) AS [Batting Average]
FROM People As p JOIN Batting AS b
ON p.playerID = b.playerID
JOIN Salaries AS s
ON p.playerID = s.playerID
AND s.playerID = b.playerID
AND s.teamID = b.teamID
AND s.yearID = b.yearID
WHERE p.birthState = 'NJ'
AND b.AB > 0
ORDER BY p.nameLast, s.yearID;
GO

--Answer to Question 3
SELECT p.playerid, 
p.birthCity, 
p.birthState,
p.birthYear,
b.yearID, 
FORMAT(s.salary, 'C') AS Salary,
CONVERT(decimal(5,4), (b.H * 1.0/ NULLIF(b.AB,0))) AS [Batting Average]
FROM People As p LEFT JOIN Batting AS b
ON p.playerID = b.playerID
LEFT JOIN Salaries AS s
ON p.playerID = s.playerID
AND s.playerID = b.playerID
AND s.teamID = b.teamID
AND s.yearID = b.yearID
WHERE p.birthState = 'NJ'
AND b.AB > 0
ORDER BY p.nameLast, s.yearID;
GO

--Answer to Question 4
SELECT DISTINCT b.playerID,
c.schoolID,
b.yearID,
CONVERT(decimal(5,4), (b.H * 1.0/ NULLIF(b.AB, 0))) AS [Batting Average]
FROM Batting AS b, CollegePlaying AS c 
WHERE b.playerID = c.playerID
AND CONVERT(decimal(5,4), (b.H * 1.0/ b.AB)) < 0.4
AND b.AB > 0
AND c.schoolID IN ('Brown', 'Columbia', 'Cornell', 'Dartmouth', 'Harvard', 'Princeton', 'UPenn', 'Yale')
ORDER BY c.schoolID ASC, [Batting Average] DESC;
GO

--Answer to Question 5
(SELECT playerID, teamID FROM Batting WHERE yearID = '2010')
INTERSECT
(SELECT playerID, teamID FROM Batting WHERE yearID = '2020')
GO

--Answer to Question 6
(SELECT playerID, teamID FROM Batting WHERE yearID = '2015')
EXCEPT
(SELECT playerID, teamID FROM Batting WHERE yearID = '2020')
GO

--Answer to Question 7
SELECT playerID,
FORMAT(AVG(salary), 'C') AS [Average Salary],
FORMAT(SUM(salary), 'C') AS [Total Salary]
FROM Salaries
GROUP BY playerID
ORDER BY [Total Salary] DESC;
GO

--Answer to Question 8
SELECT p.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
SUM(b.HR) AS [Total Home Runs],
SUM(yearID) AS [Total Years Played]
FROM People AS p,
Batting AS b
WHERE p.playerID = b.playerID
GROUP BY p.playerID, p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] 
HAVING SUM(b.HR) > 500;
GO

--Answer to Question 9
select a.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
t.name
FROM Appearances as a inner join Teams as t
on a.teamID = t.teamID and a.yearID = t.yearID
inner join People P on P.playerID = A.playerID
where 
a.yearID = '2020' and 
 t.teamID IN (
    select teamID
from Teams
where yearID = '1910'
) group by a.playerID, p.nameLast, p.nameFirst, p.nameGiven, t.name
order by p.nameLast
GO

--Answer to Question 10
SELECT s.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
s.teamID,
a.[Last Year],
FORMAT(a.[Player Average], 'C') AS [Player Average],
FORMAT(b.[Team Average], 'C') AS [Team Average],
FORMAT((Cast(a.[Player Average] AS float) - (cast(b.[Team Average] AS float))), 'C') AS Difference
FROM Salaries AS s INNER JOIN  People AS p
ON p.playerID = s.playerID
INNER JOIN (
    SELECT  playerID, teamID, AVG(salary) AS [Player Average], MAX(yearID) AS [Last Year]
    FROM Salaries
    GROUP BY playerID, teamID
) AS a
ON a.playerID = s.playerID
and a.teamID = s.teamID
INNER JOIN (
    SELECT teamID, AVG(salary) AS [Team Average]
    FROM Salaries
    GROUP BY teamID
) AS b
ON b.teamID = s.teamID
GROUP BY s.playerID, p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast], s.teamID, a.[Last Year], [Player Average], [Team Average]
ORDER BY a.[Last Year] DESC, s.playerID;
GO

--Answer to Question 11
WITH Player_Average AS (
    SELECT playerID, teamID, AVG(salary) AS [Player Average]
    FROM Salaries
    GROUP BY playerID, teamID
),
Team_Average AS (
    SELECT teamID, AVG(salary) AS [Team Average]
    FROM Salaries
    GROUP BY teamID
)
SELECT s.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
s.teamID,
MAX(yearID) AS [Last Year],
FORMAT(Player_Average.[Player Average], 'C') AS [Player Average],
FORMAT(Team_Average.[Team Average], 'C') AS [Team Average],
FORMAT((Cast(Player_Average.[Player Average] AS float) - (cast(Team_Average.[Team Average] AS float))), 'C') AS Difference
FROM Salaries s, People p, Player_Average, Team_Average
WHERE s.playerID = p.playerID
AND Player_Average.playerID = s.playerID
AND Player_Average.teamID = s.teamID
AND Team_Average.teamID = s.teamID
GROUP BY s.playerID, p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast], s.teamID, Player_Average.[Player Average], Team_Average.[Team Average]
ORDER BY MAX(yearID) DESC, s.playerID;
GO

--Answer to Question 12
SELECT p.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
FORMAT(AVG(s.salary), 'C') AS [Average Salary],
(SELECT Count(teamID) FROM Salaries s where s.playerID = p.playerID) AS [Total Teams]
FROM Salaries s INNER JOIN People p
ON s.playerID = p.playerID
GROUP BY p.playerID, p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast]
GO

--Answer to Question 13
UPDATE Salaries
SET [401K Contributions] = 0.06 * salary
GO

--Answer to Question 14
UPDATE Salaries
SET [401K Team Contributions] = 
CASE 
WHEN salary < 1000000.0000 THEN 0.05 * salary
WHEN salary > 1000000.0000 THEN 0.025 * salary
END
GO

--Answer to Question 15
SELECT playerID, yearID, 
FORMAT(salary, 'C'), 
FORMAT([401K Contributions], 'C') AS Player_401k, 
FORMAT([401K Team Contributions], 'C') AS Team_401k, 
FORMAT(([401K Contributions] + [401K Team Contributions]), 'C') AS [401k Total]
FROM Salaries
WHERE salary IS NOT NULL
ORDER BY playerID
GO

--Answer to Question 16
UPDATE People
SET People.Total_HR = B_Values.Sum_HR,
    People.High_BA = B_Values.Max_BA
FROM (SELECT playerID, SUM(HR) AS Sum_HR, MAX(H * 1.0/ AB) AS Max_BA FROM Batting WHERE AB > 0 GROUP BY playerID) AS B_Values
WHERE B_Values.playerID = People.playerID
AND B_Values.playerID = People.playerID
GO

--Answer to Question 17
SELECT playerID, Total_HR, CONVERT(decimal(5,4), High_BA) AS High_BA
FROM People
ORDER BY playerID
GO

--Answer to Question 18
UPDATE People
SET People.Total_401K = Total.TOtal_401k
FROM (SELECT playerID, ISNULL(SUM([401K Contributions]) + SUM([401K Team Contributions]), 0) AS Total_401k from Salaries GROUP BY playerID) AS Total
WHERE Total.playerID = People.playerID
GO

--Answer to Question 19
SELECT p.playerID,
p.[nameGiven] + '('+ p.[nameFirst] +')' + p.[nameLast] AS [Full Name],
FORMAT(p.Total_401K, 'C')
FROM People p
WHERE Total_401K IS NOT NULL
ORDER BY playerID

--Answer to Question 20
Select people.playerid, (nameGiven + ' ( ' + nameFirst + ' ) ' + NameLast) as Full_Name,
       s.yearid,
       format(s.salary,'C') as Salary,
       format(sp.salary,'C') as prior_year,
       format((s.salary - sp.salary),'C') as Salary_Difference,
       format(((s.salary - sp.salary)/sp.salary),'P') as Salary_Increase
from people, salaries s, salaries sp
       where people.playerid = s.playerid and
       sp.yearid = s.yearid-1 and
       sp.teamid = s.teamid and
       sp.lgid = s.lgid and
       sp.playerid = people.playerid
order by playerid asc, yearid desc

-- select salary AS Current_Salary, yearID from Salaries where playerID='aardsda01' and yearID = (select MAX(yearID)-1 from Salaries where playerID='aardsda01')
-- select salary AS Prior_Salary, yearID from Salaries where playerID='aardsda01' and yearID = (select MAX(yearID)-2 from Salaries where playerID='aardsda01')
