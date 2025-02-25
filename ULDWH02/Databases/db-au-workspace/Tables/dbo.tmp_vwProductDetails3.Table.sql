USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_vwProductDetails3]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_vwProductDetails3](
	[PolicyID] [int] NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[DomainID] [int] NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PlanCode] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [vwProductDetails3_PolicyNumber]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [vwProductDetails3_PolicyNumber] ON [dbo].[tmp_vwProductDetails3]
(
	[PolicyNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [vwProductDetails3_DomainID]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [vwProductDetails3_DomainID] ON [dbo].[tmp_vwProductDetails3]
(
	[DomainID] ASC
)
INCLUDE([CompanyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
