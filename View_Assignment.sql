IF OBJECT_ID ('tt347_Player_History', 'V') IS NOT NULL
DROP VIEW Baseball_Averages
GO

CREATE VIEW tt347_Player_History (playerID, FullName, Total_Teams, Batting_Total_Years, Total_Salary, Average_Salary, Total_401k, Last_Year_College, 
Last_Year_Batting, Batting_Average, Total_HR, Total_Wins, Total_SO, Total_Awards_Player, Total_Awards_Manager, Hall_Of_Fame_Inducted_Years, Nominated_Year)
AS 
WITH A as (SELECT playerID,
[nameGiven] + '('+ [nameFirst] +')' + [nameLast] AS Full_Name,
Total_401K
FROM People
GROUP BY playerID, [nameGiven] + '('+ [nameFirst] +')' + [nameLast], Total_401K),
B AS ( SELECT
playerID,
COUNT(teamID) AS Total_Teams,
COUNT(yearID) AS Batting_Total_Years,
MAX(yearID) AS Last_Year_Batting,
(SUM([H]* 1.0)/ SUM([AB])) AS Batting_Average,
SUM(HR) AS Total_HR
FROM Batting
WHERE AB > 0
GROUP BY playerID
),
C AS ( SELECT
playerID,
SUM(salary) AS Total_Salary,
AVG(salary) AS Average_Salary
FROM Salaries
GROUP BY playerID
),
D AS (
SELECT playerID, MAX(yearID) AS Last_Year_College FROM CollegePlaying
GROUP BY playerID
),
E AS (
SELECT playerID, SUM(W) AS Total_Wins,
SUM(SO) AS Total_SO
FROM Pitching
GROUP BY playerID
),
F AS (
    SELECT ap.playerID, COUNT(ap.awardID)+ COUNT(asp.awardID) AS Total_Awards_Player
    FROM AwardsPlayers ap JOIN AwardsSharePlayers asp 
    ON ap.playerID = asp.playerID
    GROUP BY ap.playerID
),
G AS (
    SELECT am.playerID, COUNT(am.awardID) + COUNT(asm.awardID) AS Total_Awards_Manager
    FROM AwardsManagers am JOIN AwardsShareManagers asm
    ON am.playerID = asm.playerID
    GROUP BY am.playerID
),
H AS (
    SELECT hof.playerID, Hall_Of_Fame_Inducted_Years.Count_Y, Count_N
    FROM (SELECT playerID, COUNT(yearID) AS Count_Y FROM HallOfFame WHERE inducted='Y' GROUP BY playerID) AS Hall_Of_Fame_Inducted_Years,
    (SELECT playerID, COUNT(yearID) AS Count_N FROM HallOfFame hf WHERE inducted='N' GROUP BY playerID) AS Nominated_Year,
    HallOfFame hof 
    WHERE hof.playerID = Hall_Of_Fame_Inducted_Years.playerID
    and hof.playerID = Nominated_Year.playerID
)
SELECT A.playerID, A.Full_Name, B.Total_Teams, B.Batting_Total_Years, C. Total_Salary, C.Average_Salary, A.Total_401K, D.Last_Year_College, B.Last_Year_Batting, 
B.Batting_Average, B.Total_HR, E.Total_Wins, E.Total_SO, F.Total_Awards_Player, G.Total_Awards_Manager, H.Count_Y, H.Count_N
FROM A LEFT JOIN B ON A.playerID = B.playerID
LEFT JOIN C ON A.playerID = C.playerID
LEFT JOIN D ON C.playerID = D.playerID
LEFT JOIN E ON D.playerID = E.playerID
LEFT JOIN F ON E.playerID = F.playerID
LEFT JOIN G ON F.playerID = G.playerID
LEFT JOIN H ON G.playerID = H.playerID
GO

SELECT playerID, FullName, Total_Teams, Batting_Total_Years, Total_Salary, Average_Salary, Total_401k, Last_Year_College, 
Last_Year_Batting, Batting_Average, Total_HR, Total_Wins, Total_SO, Total_Awards_Player, Total_Awards_Manager, Hall_Of_Fame_Inducted_Years, Nominated_Year
FROM tt347_Player_History
GO

SELECT t.playerID, AVG(t.Batting_Total_Years) AS AvgYrsPlayed, FORMAT(t.Average_Salary, 'C') AS AvgSalary, CONVERT(decimal(5,4), t.Batting_Average) AS Batting_Average
FROM tt347_Player_History t, People p
WHERE p.nameLast LIKE 'a%'
AND t.playerID = p.playerID
GROUP BY t.playerID, t.Batting_Average, t.Average_Salary
GO