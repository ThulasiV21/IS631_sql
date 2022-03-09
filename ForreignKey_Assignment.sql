-- 1 AllStarFull
-- a. In All Stars table adding PeopleID as Foreign Key
ALTER TABLE AllStarFull
ADD FOREIGN KEY (PlayerID) REFERENCES People(playerID);
GO

-- Add primary key contraint on teams table
ALTER TABLE [dbo].[Teams] Add Primary Key (yearID, lgID, teamID);
GO

-- b. Teams Table
-- First aldjust LgID length 
ALTER TABLE AllStarFull
ALTER COLUMN LgID [varchar](255) NOT NULL;
GO

-- Add Foreign key in AllStarFull
ALTER TABLE AllStarFull
ADD FOREIGN KEY (YearID, LgID, Teamid) REFERENCES Teams(yearID, lgID, teamID);
GO


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- 2 Teams
-- Make Franchise ID on teams table non nullable
ALTER TABLE [dbo].[Teams]
ALTER COLUMN [franchID] [varchar](255) NOT NULL;
GO

-- Make Franchise ID on TeamsFranchises table non nullable
ALTER TABLE [dbo].[TeamsFranchises]
ALTER COLUMN [franchID] [varchar](255) NOT NULL;
GO

-- Add primary key constraint on teams franchise table
ALTER TABLE [dbo].[TeamsFranchises]
Add Primary Key (franchID);
GO

-- Add Foreign key constraint between Teams and TeamsFranchises table
ALTER TABLE [dbo].[Teams] ADD FOREIGN KEY (franchID) REFERENCES TeamsFranchises(franchID)
GO


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- 3 HomeGames

-- Alter length and make non nullable of lgid, teamId, yearId on HomeGames
ALTER TABLE [dbo].[HomeGames]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[HomeGames]
ALTER COLUMN [teamId] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[HomeGames]
ALTER COLUMN [yearId] [int] NOT NULL;
GO

-- Add Foreign key constraing between HomeGames and Teams table
ALTER TABLE HomeGames
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Make Park ID non nullable
ALTER TABLE [dbo].[HomeGames]
ALTER COLUMN [parkID] [VARCHAR](255) NOT NULL;
GO

-- Make park_key non nullable and 255 characters 

ALTER TABLE [dbo].[Parks]
ALTER COLUMN [park_key] [VARCHAR](255) NOT NULL;
GO

-- Add primary key on Parks table
ALTER TABLE [dbo].[Parks]
Add Primary Key (park_key);
GO


-- Add Foreign Key from HomeGames to Parks table
ALTER TABLE [dbo].[HomeGames] 
ADD FOREIGN KEY (parkID) REFERENCES Parks(park_key)
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
 -- Appearances

--  Make columns non nullable anf change column char length
ALTER TABLE [dbo].[Appearances]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Appearances]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Appearances]
ALTER COLUMN [teamID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Appearances]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Make foreign Key in Appearances referencing to Teams Table 
ALTER TABLE [dbo].[Appearances] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Make foreign Key in Appearances referencing to Players Table 
ALTER TABLE [dbo].[Appearances] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-- Delete the extar rows in Appearances table where playerID in people table is null or not present
DELETE
FROM Appearances
WHERE playerID IN (
        SELECT A.playerID AS playerID
        FROM Appearances A
        LEFT JOIN People P
            ON A.playerID = P.playerID
        WHERE P.playerID IS NULL
        );
GO
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- 4 Batting Table

-- Alter length and make non nullable of lgid, teamId, yearId, lgId in Batting
ALTER TABLE [dbo].[Batting]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Batting]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Batting]
ALTER COLUMN [teamId] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Batting]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key in Batting referencing to contraint to teams table
ALTER TABLE [dbo].[Batting] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Add Foreign Key in Batting referencing to contraint to People table
ALTER TABLE [dbo].[Batting] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Salaries


--  Make columns non nullable and adjust the char length of columns
ALTER TABLE [dbo].[Salaries]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Salaries]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Salaries]
ALTER COLUMN [teamID] [VARCHAR](255) NOT NULL;
GO

ALTER TABLE [dbo].[Salaries]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Make foreign Key in Salaries referencing to Players Table 
ALTER TABLE [dbo].[Appearances] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-- Make foreign Key in Salaries referencing to Teams Table 
ALTER TABLE [dbo].[Salaries] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Update the ldID values in Salaries table according to the values in Teams table where 
-- teamID in ('HOU', 'ari', 'lan', 'phi', 'NYN', 'CHN') and yeaID=2019
UPDATE Salaries
SET lgID = (
        SELECT lgID
        FROM Teams
        WHERE Teams.teamID IN ('HOU', 'ari', 'lan', 'phi', 'NYN', 'CHN')
            AND yearID = 2019
            AND Salaries.teamID = Teams.teamID
        )
WHERE teamID IN ('HOU', 'ari', 'lan', 'phi', 'NYN', 'CHN')
    AND yearID = 2019;
GO
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Managers

-- Alter length and make non nullable of lgid, teamId, yearId, lgId on Managers
ALTER TABLE [dbo].[Managers]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Managers]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Managers]
ALTER COLUMN [teamID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Managers]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key Constraint Team
ALTER TABLE [dbo].[Managers] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[Managers] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Awards Players 

-- Alter length and make non nullable of playerID on AwardsPlayers
ALTER TABLE [dbo].[AwardsPlayers]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[AwardsPlayers] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- AwardsManagers

-- Alter length and make non nullable of playerID on AwardsManagers
ALTER TABLE [dbo].[AwardsManagers]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[AwardsManagers] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- AwardsShareManagers

-- Make column non nullable
ALTER TABLE [dbo].[AwardsShareManagers]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[AwardsShareManagers] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- AwardsSharePlayers

-- Make column non nullable
ALTER TABLE [dbo].[AwardsSharePlayers]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[AwardsSharePlayers] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Fielding

-- Alter length and make non nullable of lgid, teamId, yearId, lgId on Fielding
ALTER TABLE [dbo].[Fielding]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Fielding]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Fielding]
ALTER COLUMN [teamID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Fielding]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key Constraint Team
ALTER TABLE [dbo].[Fielding] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[Fielding] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- HallOfFame

-- Make column non nullable
ALTER TABLE [dbo].[HallOfFame]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[HallOfFame] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Pitching

-- Alter length and make non nullable of lgid, teamId, yearId, lgId on Pitching
ALTER TABLE [dbo].[Pitching]
ALTER COLUMN [yearID] [int] NOT NULL;
GO

ALTER TABLE [dbo].[Pitching]
ALTER COLUMN [lgID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Pitching]
ALTER COLUMN [teamID] [VARCHAR](255) NOT NULL;
GO


ALTER TABLE [dbo].[Pitching]
ALTER COLUMN [playerID] [VARCHAR](255) NOT NULL;
GO

-- Add Foreign Key Constraint Team
ALTER TABLE [dbo].[Pitching] 
ADD FOREIGN KEY (yearID, lgID, teamID) REFERENCES Teams(yearID, lgID, teamID);
GO

-- Add Foreign Key Constraint People
ALTER TABLE [dbo].[Pitching] 
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO