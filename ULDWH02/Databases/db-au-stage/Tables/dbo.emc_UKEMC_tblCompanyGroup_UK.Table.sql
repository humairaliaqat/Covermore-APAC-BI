USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblCompanyGroup_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblCompanyGroup_UK](
	[CompanyGroupId] [int] NOT NULL,
	[CompId] [int] NOT NULL,
	[CLGROUP] [char](2) NOT NULL
) ON [PRIMARY]
GO
