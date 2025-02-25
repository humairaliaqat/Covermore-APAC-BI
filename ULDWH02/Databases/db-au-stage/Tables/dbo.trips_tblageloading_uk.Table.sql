USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tblageloading_uk]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tblageloading_uk](
	[planid] [int] NOT NULL,
	[durationid] [int] NOT NULL,
	[agebracket] [varchar](10) NULL,
	[netrate] [float] NULL,
	[clgroup] [varchar](10) NULL,
	[b2bonly] [varchar](1) NOT NULL
) ON [PRIMARY]
GO
