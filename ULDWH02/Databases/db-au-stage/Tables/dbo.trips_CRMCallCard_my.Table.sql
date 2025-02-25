USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_CRMCallCard_my]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_CRMCallCard_my](
	[CRMCallCardID] [numeric](18, 0) NOT NULL,
	[CRMCallsID] [numeric](18, 0) NULL,
	[SalesRepCallCardID] [numeric](18, 0) NULL,
	[CLALPHA] [char](7) NULL,
	[CallDate] [datetime] NULL,
	[CallTime] [datetime] NULL,
	[CallRemarks] [varchar](4000) NULL,
	[PersonalRemarks] [varchar](1000) NULL,
	[REP] [varchar](50) NULL,
	[REPTYPE] [varchar](20) NULL
) ON [PRIMARY]
GO
