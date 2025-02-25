USE [db-au-actuary]
GO
/****** Object:  Table [ws].[PolicyLineage]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[PolicyLineage](
	[BIRowID] [bigint] NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[AncestorPolicyKey] [varchar](41) NULL,
	[AncestorPolicyNo] [int] NULL,
	[AncestorCustomerKey] [varchar](41) NULL,
	[ParentPolicyKey] [varchar](41) NULL,
	[ParentPolicyNo] [int] NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNo] [int] NULL,
	[CustomerKey] [varchar](41) NULL,
	[Depth] [int] NULL,
 CONSTRAINT [PK_PolicyLineage] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_parent] ON [ws].[PolicyLineage]
(
	[PolicyKey] ASC
)
INCLUDE([AncestorPolicyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxKey] ON [ws].[PolicyLineage]
(
	[AncestorPolicyKey] ASC,
	[Depth] ASC
)
INCLUDE([CountryKey],[AncestorPolicyNo],[AncestorCustomerKey],[PolicyKey],[PolicyNo],[CustomerKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxNo]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxNo] ON [ws].[PolicyLineage]
(
	[AncestorPolicyNo] ASC
)
INCLUDE([CountryKey],[AncestorPolicyKey],[AncestorCustomerKey],[PolicyKey],[PolicyNo],[CustomerKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxp]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxp] ON [ws].[PolicyLineage]
(
	[PolicyNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
