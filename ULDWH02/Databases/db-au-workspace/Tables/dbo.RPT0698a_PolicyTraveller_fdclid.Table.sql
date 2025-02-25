USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[RPT0698a_PolicyTraveller_fdclid]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPT0698a_PolicyTraveller_fdclid](
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[BatchNumber] [varchar](2) NULL,
	[ExternalReference2] [nvarchar](225) NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[IssueDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
