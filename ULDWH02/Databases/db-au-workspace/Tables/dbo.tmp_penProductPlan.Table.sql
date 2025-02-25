USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_penProductPlan]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_penProductPlan](
	[ProductKey] [varchar](67) NULL,
	[DomainID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductCode] [nvarchar](50) NOT NULL,
	[PlanID] [int] NOT NULL,
	[UniquePlanID] [int] NOT NULL,
	[PlanCode] [nvarchar](10) NOT NULL,
	[PlanName] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penProduct_ProductID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_penProduct_ProductID] ON [dbo].[tmp_penProductPlan]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penProduct_PlanID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_penProduct_PlanID] ON [dbo].[tmp_penProductPlan]
(
	[PlanID] ASC
)
INCLUDE([UniquePlanID],[DomainID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
