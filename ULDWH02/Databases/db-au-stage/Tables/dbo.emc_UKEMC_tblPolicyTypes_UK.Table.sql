USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblPolicyTypes_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblPolicyTypes_UK](
	[PolTypeID] [tinyint] NOT NULL,
	[PolCode] [varchar](3) NULL,
	[PolType] [varchar](100) NULL,
	[SortOrder] [int] NULL,
	[Tripspolcode] [varchar](10) NULL
) ON [PRIMARY]
GO
