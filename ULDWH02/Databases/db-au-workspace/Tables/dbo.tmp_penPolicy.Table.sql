USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_penPolicy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_penPolicy](
	[PolicyID] [int] NOT NULL,
	[DomainID] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[ProductID] [int] NOT NULL,
	[PlanID] [int] NULL,
	[UniquePlanID] [int] NOT NULL,
	[PlanCode] [nvarchar](50) NULL
) ON [PRIMARY]
GO
