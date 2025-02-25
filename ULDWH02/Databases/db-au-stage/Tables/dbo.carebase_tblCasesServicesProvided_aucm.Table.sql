USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblCasesServicesProvided_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblCasesServicesProvided_aucm](
	[CaseNo] [varchar](14) NOT NULL,
	[ServiceTypeID] [int] NULL,
	[Amount] [money] NULL
) ON [PRIMARY]
GO
