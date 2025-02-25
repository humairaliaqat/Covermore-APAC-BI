USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_stnorder_nz]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_stnorder_nz](
	[STID] [int] NOT NULL,
	[DATEAD] [datetime] NULL,
	[CONSULTANT] [varchar](5) NULL,
	[CLALPHA] [varchar](7) NULL,
	[CMOB] [int] NULL,
	[CMBB] [int] NULL,
	[ESSB] [int] NULL,
	[CLAIMFORM] [int] NULL,
	[ASSFORM] [int] NULL,
	[ASSCARDS] [int] NULL,
	[DECPADS] [int] NULL,
	[POLWALLET] [int] NULL,
	[SALESRETURN] [int] NULL,
	[QUICKTIPS] [int] NULL,
	[CORPORATEQUOTES] [int] NULL,
	[COMMENTS] [varchar](255) NULL,
	[EMAIL] [varchar](70) NULL,
	[CMSB] [int] NOT NULL
) ON [PRIMARY]
GO
