USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Site_Lookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Site_Lookup](
	[uniquesiteid] [nvarchar](4000) NOT NULL,
	[ksiteid] [int] NOT NULL,
	[preexisting] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
