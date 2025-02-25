USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cmp_Claim_ODS]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmp_Claim_ODS](
	[ClaimNo] [int] NOT NULL,
	[IssueDate] [date] NULL,
	[LossDate] [date] NULL,
	[Estimate] [decimal](38, 6) NOT NULL,
	[Paid] [money] NOT NULL
) ON [PRIMARY]
GO
