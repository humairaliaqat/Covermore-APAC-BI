USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblEmcApproval_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblEmcApproval_UK](
	[CLIENTID] [int] NULL,
	[CONDITION] [varchar](50) NULL,
	[DENIEDACCEPTED] [varchar](1) NULL
) ON [PRIMARY]
GO
