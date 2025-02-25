USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimTime_AU]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimTime_AU](
	[DimTimeID] [int] NOT NULL,
	[Time] [char](8) NOT NULL,
	[Hour] [char](2) NOT NULL,
	[MilitaryHour] [char](2) NOT NULL,
	[Minute] [char](2) NOT NULL,
	[Second] [char](2) NOT NULL,
	[AmPm] [char](2) NOT NULL,
	[StandardTime] [char](11) NULL
) ON [PRIMARY]
GO
