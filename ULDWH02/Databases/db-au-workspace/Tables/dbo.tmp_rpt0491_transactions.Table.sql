USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0491_transactions]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0491_transactions](
	[PolicyKey] [varchar](41) NULL,
	[PolicyNoKey] [varchar](100) NULL,
	[IssueDate] [date] NOT NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[TravellersCount] [int] NULL
) ON [PRIMARY]
GO
