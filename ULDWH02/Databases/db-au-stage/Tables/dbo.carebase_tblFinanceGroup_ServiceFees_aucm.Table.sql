USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblFinanceGroup_ServiceFees_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblFinanceGroup_ServiceFees_aucm](
	[GroupID] [int] NULL,
	[ServiceTypeID] [int] NULL,
	[FEE] [money] NULL
) ON [PRIMARY]
GO
