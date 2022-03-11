-- Question 1
SELECT i.playerID
    , dbo.FullName(i.playerID) AS [Full Name]
    , i.CareerBA
    , rank() OVER (
        ORDER BY i.CareerBA DESC
        ) AS [BA Rank]
FROM IS631View i
WHERE i.CareerBA < 0.40
GO




-- Question 2
SELECT i.playerID
    , dbo.FullName(i.playerID) AS [Full Name]
    , i.CareerBA
    , dense_rank() OVER (
        ORDER BY i.CareerBA DESC
        ) AS [BA Rank]
FROM IS631View i
WHERE i.CareerBA < 0.40
GO




-- Question 3
SELECT i.playerID
    , dbo.FullName(i.playerID) AS [Full Name]
    , i.LastPlayed
    , i.CareerBA
    , dense_rank() OVER (
        ORDER BY i.LastPlayed DESC
            , i.CareerBA DESC
        ) AS [BA Rank]
FROM IS631View i
WHERE i.CareerBA > 0.00
GO




-- Question 4
SELECT i.playerID
    , dbo.FullName(i.playerID) AS [Full Name]
    , i.LastPlayed
    , i.CareerBA
    , NTILE(4) OVER (
        ORDER BY i.LastPlayed DESC
            , i.CareerBA DESC
        ) AS [Ntile]
FROM IS631View i
WHERE i.CareerBA > 0.00
GO




-- Question 5
select a.teamid, a.yearid, format([Year Avg],'C') as [Year Average], 
       format(avg([Year Avg]) over (order by yearid rows between 3 preceding and 1 following),'C')
       as [Windowed Avg]
                    from (select teamid, yearid, avg(salary) as [Year Avg]
                                 from salaries
                                 group by teamid, yearid 
                           ) A
       order by teamid, yearid
GO
-- SELECT s.teamID, s.yearID, FORMAT(AVG(s.salary), 'C') AS Average_Salary,
-- A.Windowed_Salary
-- FROM Salaries s,
-- (
--     SELECT teamID, yearID, AVG(salary) AS Avg_salary, FORMAT(SUM(salary) OVER (PARTITION BY teamID ORDER BY yearID ROWS BETWEEN 3 preceding and 1 following), 'C') AS Windowed_Salary FROM Salaries GROUP BY teamID, yearID, salary 
-- ) A
-- WHERE S.teamID = A.teamID AND S.yearID = A.yearID
-- GROUP BY s.teamID, s.yearID, A.Windowed_Salary

-- Question 6
SELECT ba.teamID
    , ba.playerID
    , dbo.FullName(ba.playerID) AS [FUll Name]
    , SUM(ba.H) AS [Total Hits]
    , SUM(ba.AB) AS [Total At Bats]
    , CONVERT(DECIMAL(5, 4), SUM(ba.H) * 1.0 / SUM(ba.AB)) AS [Batting Average]
    , Team_BA_rank AS [Team Batting Rank]
    , BA_rank AS [All Batting Rank]
FROM (
    SELECT teamid
        , playerid
        , cast(sum(h * 1.0) / sum(ab) AS DECIMAL(5, 4)) AS player_ba
        , rank() OVER (
            PARTITION BY teamid ORDER BY (sum(h * 1.0) / sum(ab)) DESC
            ) AS ba_rank
    FROM batting
    GROUP BY teamid
        , playerid
    HAVING sum(ab) > 0
    ) A
    , (
        SELECT teamid
            , sum(h) AS h
            , sum(ab) AS ab
            , sum(h * 1.0) / sum(ab) AS team_BA
            , rank() OVER (
                ORDER BY sum(h * 1.0) / sum(ab) DESC
                ) AS Team_ba_rank
        FROM teams
        GROUP BY teamid
        ) B
    , Batting ba
WHERE a.teamid = b.teamid
    AND A.playerID = ba.playerID
    AND ba.AB > 0
GROUP BY ba.teamID
    , ba.playerID
    , dbo.FullName(ba.playerID)
    , Team_BA_rank
    , BA_rank
HAVING SUM(ba.H) > 150
ORDER BY Team_BA_rank
    , BA_rank;
GO




-- Question 7
WITH t AS (
   SELECT  lgid, teamid, yearid, playerid, ROW_NUMBER() OVER (PARTITION BY  lgid, teamid, yearid, playerid ORDER BY  lgid, teamid, yearid, playerid) AS row_numb
   FROM Salaries
)
DELETE FROM t
WHERE row_numb > 1 

-- Question 7 Adding Primary Key
ALTER TABLE [dbo].[Salaries] Add Primary Key (playerID, teamID, yearID, lgID );
GO
