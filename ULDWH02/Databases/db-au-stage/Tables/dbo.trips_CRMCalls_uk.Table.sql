USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_CRMCalls_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_CRMCalls_uk](
	[CRMCallsID] [numeric](18, 0) NOT NULL,
	[CLALPHA] [char](7) NULL,
	[CONSULTANT] [varchar](50) NULL,
	[ATTITUDE] [numeric](18, 0) NULL,
	[CATEGORY] [varchar](100) NULL,
	[SUBCATEGORY] [varchar](100) NULL,
	[SUBCATDETAILS] [varchar](100) NULL,
	[CallDate] [datetime] NULL,
	[CallTime] [datetime] NULL
) ON [PRIMARY]
GO
