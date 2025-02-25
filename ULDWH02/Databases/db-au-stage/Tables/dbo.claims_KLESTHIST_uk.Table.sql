USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLESTHIST_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLESTHIST_uk](
	[EH_ID] [int] NOT NULL,
	[EHIS_ID] [int] NULL,
	[EHESTIMATE] [money] NULL,
	[EHCREATED] [datetime] NULL,
	[EHCREATEDBY_ID] [int] NULL
) ON [PRIMARY]
GO
