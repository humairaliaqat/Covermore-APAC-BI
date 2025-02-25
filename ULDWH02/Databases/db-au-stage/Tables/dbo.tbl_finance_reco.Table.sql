USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tbl_finance_reco]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_finance_reco](
	[Source Business Unit] [varchar](50) NULL,
	[Source Period] [varchar](50) NULL,
	[Source GL Amount] [varchar](50) NULL,
	[BI Business Unit] [varchar](50) NULL,
	[BI Period] [varchar](50) NULL,
	[BI GL Amount] [varchar](50) NULL,
	[Variance] [varchar](50) NULL
) ON [PRIMARY]
GO
