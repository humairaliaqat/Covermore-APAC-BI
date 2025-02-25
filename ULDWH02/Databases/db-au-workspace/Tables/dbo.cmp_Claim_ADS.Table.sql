USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cmp_Claim_ADS]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmp_Claim_ADS](
	[ClaimNo] [int] NOT NULL,
	[IssueMonth] [date] NULL,
	[LossMonth] [date] NULL,
	[Estimate] [decimal](38, 6) NULL,
	[Paid] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
