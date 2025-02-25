USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tblCFAR_PolicyList_temp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCFAR_PolicyList_temp](
	[PolicyNumber] [varchar](20) NULL,
	[BaseComponent] [int] NULL,
	[CancelComponent] [int] NULL
) ON [PRIMARY]
GO
