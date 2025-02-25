USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_cds]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_cds](
	[ClaimNo] [int] NOT NULL,
	[StatusAtEndOfDay] [nvarchar](100) NOT NULL,
	[Estimate] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
