USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_day]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_day](
	[Date] [smalldatetime] NOT NULL,
	[PolicyCount] [int] NULL,
	[TravellerCount] [int] NULL
) ON [PRIMARY]
GO
