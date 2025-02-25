USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_dcaccount_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_dcaccount_nz](
	[DCACCOUNTID] [int] NOT NULL,
	[DCALPHA] [varchar](7) NULL,
	[DCACCNAME] [varchar](50) NULL,
	[BSB] [varchar](10) NULL,
	[DCACCNO] [varchar](20) NULL,
	[DCACCEMAIL] [varchar](100) NULL
) ON [PRIMARY]
GO
