USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Policy_PolicyStatus_Discrepancies]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy_PolicyStatus_Discrepancies](
	[CountryKey] [varchar](2) NULL,
	[policykey] [varchar](41) NULL,
	[Src_policyno] [varchar](25) NULL,
	[BI_policyno] [varchar](50) NULL,
	[Src_PolicyStatusCode] [int] NULL,
	[BI_PolicyStatusCode] [int] NULL,
	[BI_IssueDate] [datetime] NULL,
	[BI_IssueDateUTC] [datetime] NULL,
	[CancelledDate] [datetime] NULL
) ON [PRIMARY]
GO
