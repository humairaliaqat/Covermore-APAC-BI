USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\mercedee].[CustomersCluster2018AU]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\mercedee].[CustomersCluster2018AU](
	[PolicyTravellerKey] [varchar](255) NULL,
	[CustomerID] [int] NULL,
	[PolicyKey] [varchar](255) NULL,
	[cluster] [int] NULL,
	[tsneV1] [float] NULL,
	[tsneV2] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PolicyKey]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [IX_PolicyKey] ON [COVERMORE\mercedee].[CustomersCluster2018AU]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PolicyTravellerKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PolicyTravellerKey] ON [COVERMORE\mercedee].[CustomersCluster2018AU]
(
	[PolicyTravellerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
