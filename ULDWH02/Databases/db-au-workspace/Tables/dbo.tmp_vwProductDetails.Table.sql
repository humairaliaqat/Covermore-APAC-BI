USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_vwProductDetails]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_vwProductDetails](
	[PolicyID] [int] NOT NULL,
	[DomainID] [int] NOT NULL,
	[Company] [nvarchar](3) NOT NULL,
	[IssueDate] [datetime] NOT NULL,
	[ProductId] [int] NOT NULL,
	[ProductCode] [nvarchar](50) NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductDisplayName] [nvarchar](50) NULL,
	[UniquePlanID] [int] NOT NULL,
	[PlanID] [int] NOT NULL,
	[PlanName] [nvarchar](50) NOT NULL,
	[PlanCode] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_vwProductDetails_PolicyID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_vwProductDetails_PolicyID] ON [dbo].[tmp_vwProductDetails]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_vwProductDetails_IssueDate]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_vwProductDetails_IssueDate] ON [dbo].[tmp_vwProductDetails]
(
	[IssueDate] ASC
)
INCLUDE([ProductId],[UniquePlanID],[PlanID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
