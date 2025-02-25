USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_Audit_tblCasesServicesProvided_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_Audit_tblCasesServicesProvided_aucm](
	[Audit_UserName] [varchar](255) NULL,
	[Audit_Datetime] [datetime] NULL,
	[Audit_Action] [varchar](10) NULL,
	[CaseNo] [varchar](14) NULL,
	[ServiceTypeID] [int] NULL,
	[Amount] [money] NULL
) ON [PRIMARY]
GO
