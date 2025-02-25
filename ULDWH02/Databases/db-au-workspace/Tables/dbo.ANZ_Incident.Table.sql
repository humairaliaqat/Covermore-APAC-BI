USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ANZ_Incident]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ANZ_Incident](
	[Business Unit] [nvarchar](255) NULL,
	[Reference Name] [nvarchar](255) NULL,
	[Incident Name] [nvarchar](255) NULL,
	[What Happened] [nvarchar](max) NULL,
	[Incident Priority] [nvarchar](255) NULL,
	[Incident Status] [nvarchar](255) NULL,
	[Date Reported] [nvarchar](255) NULL,
	[Target Close Date] [nvarchar](255) NULL,
	[Type of incident] [nvarchar](255) NULL,
	[Cause of the Incident?] [nvarchar](255) NULL,
	[Root Cause] [nvarchar](255) NULL,
	[Business Area or Agent incident originates from?] [nvarchar](255) NULL,
	[Is it a breach?] [nvarchar](255) NULL,
	[Impact] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
