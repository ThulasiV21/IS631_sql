/* Create Date Updated Column If IT Doesn't Exist            */
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'People'
                 AND COLUMN_NAME = 'tt347_Last_Update'
                 AND COLUMN_NAME = 'tt347_Total_Games_Played')
BEGIN
alter table People 
add tt347_Last_Update date default NULL,
tt347_Total_Games_Played int default NULL
END;
go

/* Run Simple Update Query To Get Time Without Transaction Processing */
Declare @today date
Set @today = convert(date, getdate())
Print 'SQL Update Command Start Time - ' + (CAST(convert(varchar,getdate(),108) AS 
nvarchar(30)))

Print 'SQL Update Command End Time - ' + (CAST(convert(varchar,getdate(),108) AS 
nvarchar(30)))

Set nocount on;
--- Run Transaction
--- Update script
-- Declare variables
DECLARE @updateCount bigint 
DECLARE @PlayerID varchar(50)
DECLARE @Sum_G INT
DECLARE @STOP int
DECLARE @ERROR INT
-- Initialize the update count
set @updateCount = 0
set @stop = 0
Print @today
Print 'Transaction Update Command Start Time - ' + 
(CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

--- Declare Cursor
DECLARE updatecursor CURSOR STATIC FOR
        SELECT A.playerID, SUM(A.G_all) AS SUM_G
            FROM Appearances A, People p
WHERE a.playerID = p.playerID
AND (p.tt347_Last_Update <> @today or p.tt347_Last_Update is Null)
GROUP BY A.playerID;

Select @@CURSOR_ROWS as 'Number of Cursor Rows After Declare'
Print 'Declare Cursor Complete Time - ' + 
(CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
--- Open Cursor
    OPEN updatecursor
Select @@CURSOR_ROWS as 'Number of Cursor Rows'
    FETCH NEXT FROM updatecursor INTO @PLayerid, @Sum_G
    WHILE @@fetch_status = 0 AND @STOP = 0
    BEGIN
-- Begin transaction for the first record
    if @updateCount = 0
    BEGIN 
      PRINT 'Begin Transaction At Record - ' + RTRIM(CAST(@updateCount AS 
nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
      BEGIN TRANSACTION
    END

Update People
set tt347_Last_Update = @today
where @PlayerID = playerID;

Update People 
set tt347_Total_Games_Played = @SUM_G
where @PlayerID = playerID;
 
   set @updateCount = @updateCount + 1
--- Abend at Record 20094
   IF @updateCount = 20094
Begin
   set @STOP = 1
End
-- Commit every 1,000 records and start a new transaction
        IF @updateCount % 10 = 0 
        BEGIN
            PRINT 'COMMIT TRANSACTION - ' + RTRIM(CAST(@updateCount AS 
nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
-- DONE WITH THE PREVIOUS GROUP, WE NEED THE NEXT
            PRINT 'END OLD TRANSACTION AT RECORD - ' + RTRIM(CAST(@updateCount AS 
nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
            COMMIT TRANSACTION
            BEGIN TRANSACTION
        END
        FETCH NEXT FROM updatecursor INTO @PLayerid, @Sum_G
    END
    IF @stop <> 1
    BEGIN
        -- COMMIT FINAL WHEN TO THE END
        PRINT 'Final Commit Transaction For Record - ' + RTRIM(CAST(@updateCount AS
nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
        COMMIT TRANSACTION
    END
IF @stop = 1
    BEGIN
        -- Rollback to last COMMIT
        PRINT 'Rollback started For Transaction at Record - ' + 
RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + 
(CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
        Rollback TRANSACTION
    END
    CLOSE updatecursor
    DEALLOCATE updatecursor
Print 'Transaction Update Command End Time - ' + 
(CAST(convert(varchar,getdate(),108) AS nvarchar(30))) + ' At - ' + 
(CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
set nocount off;

--Select from results of updatecursor
select playerID, tt347_Total_Games_Played, tt347_Last_Update as 'Count_CURSOR_Dates'
from People 