IF OBJECT_ID (N'dbo.FullName') IS NOT NULL  
    DROP FUNCTION dbo.FullName;  
GO  
CREATE FUNCTION dbo.FullName(@PlayerID VARCHAR(255))  
RETURNS VARCHAR(255)   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @FullName VARCHAR(255);  
    SELECT @FullName = nameFirst + '(' +nameGiven+ ')' + nameLast   
    FROM People p   
    WHERE p.PlayerID = @PlayerID  
    RETURN @FullName;  
END;
GO

SELECT ba.teamID, ba.playerID, dbo.FullName(ba.playerID) AS [FUll Name], 
SUM(ba.H) AS [Total Hits], 
SUM(ba.AB) AS [Total At Bats],
CONVERT(decimal(5,4), SUM(ba.H) * 1.0 / SUM(ba.AB)) AS [Batting Average],
Team_BA_rank AS [Team Batting Rank], BA_rank as [All Batting Rank] 
from (select teamid, playerid, cast(sum(h*1.0)/sum(ab) as decimal(5,4)) as 
player_ba,  
rank() over (partition by teamid order by 
(sum(h*1.0)/sum(ab)) desc) as ba_rank 
  from batting 
  group by teamid, playerid 
  having sum(ab) > 0) A, 
  (select teamid, sum(h) as h, sum(ab) as ab, sum(h*1.0)/sum(ab) as 
team_BA,  
rank() over (order by sum(h*1.0)/sum(ab) desc) as 
Team_ba_rank 
    from teams 
group by teamid) B, Batting ba 
where a.teamid = b.teamid
AND  A.playerID = ba.playerID
AND ba.AB > 0
GROUP BY ba.teamID, ba.playerID, dbo.FullName(ba.playerID), Team_BA_rank, BA_rank
HAVING SUM(ba.H) > 150
order by Team_BA_rank, BA_rank;

-- dense_rank() over (partition by b.teamID order by (sum(b.h*1.0)/sum(b.ab)) desc) as [Team Batting rank],
-- dense_rank() over (partition by b.playerID order by (sum(b.h*1.0)/sum(b.ab)) desc) as [All Batting rank]
-- FROM Batting b JOIN People p
-- ON b.playerID = p.playerID
-- WHERE 
-- HAVING SUM(b.H) > 150
-- ORDER BY [Team Batting rank], [All Batting rank];