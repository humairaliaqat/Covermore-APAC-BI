USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblCaseManagement_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblCaseManagement_aucm](
	[CaseMgtID] [int] NOT NULL,
	[Case_No] [varchar](50) NULL,
	[CSIData] [nvarchar](max) NULL,
	[TemplateID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
