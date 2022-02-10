IF OBJECT_ID (N'dbo.CollegePlaying', N'U') IS NOT NULL
DROP TABLE [dbo].[CollegePlaying]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CollegePlaying](
	[playerID] [varchar](255) NULL,
	[schoolID] [varchar](255) NULL,
	[yearID] [int] NULL CHECK (1864 <= yearID AND yearID <= 2014),
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CollegePlaying]
ADD ID [int] NOT NULL IDENTITY;
GO

ALTER TABLE [dbo].[CollegePlaying]
ADD PRIMARY KEY (ID);
GO

ALTER TABLE [dbo].[People]
ALTER COLUMN [playerID] [varchar](255) NOT NULL;
GO

ALTER TABLE [dbo].[People]
ADD PRIMARY KEY (playerID);
GO

ALTER TABLE [dbo].[Schools]
ALTER COLUMN [schoolID] [varchar](255) NOT NULL;
GO

ALTER TABLE [dbo].[Schools]
ADD PRIMARY KEY (schoolID);
GO

ALTER TABLE [dbo].[CollegePlaying]
ADD FOREIGN KEY (playerID) REFERENCES People(playerID);
GO

ALTER TABLE [dbo].[CollegePlaying]
ADD FOREIGN KEY (schoolID) REFERENCES Schools(schoolID);
GO