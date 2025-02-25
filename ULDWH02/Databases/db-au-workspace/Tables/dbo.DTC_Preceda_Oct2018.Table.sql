USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_Preceda_Oct2018]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_Preceda_Oct2018](
	[Position ID] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[First Name] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[Position Title] [nvarchar](255) NULL,
	[Reports To Position Title] [nvarchar](255) NULL,
	[Level 2 Description] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Employment Type Desc] [nvarchar](255) NULL,
	[Personnel Type Desc] [nvarchar](255) NULL,
	[Work Pattern Description] [nvarchar](255) NULL,
	[Base Hours Amount] [float] NULL,
	[FTE] [float] NULL
) ON [PRIMARY]
GO
