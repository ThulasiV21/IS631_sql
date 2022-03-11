IF OBJECT_ID('IS631view', 'V') IS NOT NULL
    DROP VIEW IS631View;
GO

create view IS631View
As
With 
Player as
(Select playerid, nameGiven + ' ( ' + nameFirst + ' ) ' + NameLast as [Full Name]
from people),
AvSalaries as
(select playerid, avg(Salary) as [Average Salary], sum(salary) as [Total Salary]
from salaries
group by playerid), 
CareerBat AS
( select playerid, sum(HR) as CareerRuns, 
convert(Decimal(6,4),(Sum(H)*1.0/sum(AB))) as CareerBA,
 Convert(Decimal(6,4),max(H*1.0/AB)) as MaxBA, max(yearid) as 
LastPlayed
from Batting
where AB > 0
group by PLayerid),
CareerPitch As
(select PLayerid, Sum(W) as CareerWins, sum(l) as CareerLoss, Sum(HR) as 
CareerPHR, Convert(Decimal(5,2),avg(ERA)) as AvgERA, MAX(ERA) as MaxERA, SUm(SO) as
[Career SO], max(so) as [High SO]
from pitching
group by playerid)
select player.playerid, player.[Full Name], 
[Average Salary], [Total Salary], CareerBA, MaxBA, CareerWins, 
CareerLoss, CareerPHR, AvgERA, MaxERA, [Career SO], [High SO], LastPlayed
from Player
left join AvSalaries on player.playerid = AvSalaries.playerID
left join CareerBat on PLayer.PLayerid = CareerBat.playerid
left join CareerPitch on player.playerid = CareerPitch.playerid
go

select * from IS631View
select count(*) from IS631View
select count(*) from people