USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Worker_Lookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Worker_Lookup](
	[uniqueworkerid] [nvarchar](4000) NOT NULL,
	[kuserid] [int] NOT NULL,
	[usloginid] [nvarchar](4000) NOT NULL,
	[kbookitemid] [int] NOT NULL,
	[kcworkerid] [int] NULL,
	[preexisting] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
