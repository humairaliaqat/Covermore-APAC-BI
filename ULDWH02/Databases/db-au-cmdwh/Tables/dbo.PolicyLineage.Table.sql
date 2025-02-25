USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PolicyLineage]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicyLineage](
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
	[Depth] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent] ON [dbo].[PolicyLineage]
(
	[PolicyKey] ASC
)
INCLUDE([AncestorPolicyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idxKey] ON [dbo].[PolicyLineage]
(
	[AncestorPolicyKey] ASC
)
INCLUDE([CountryKey],[AncestorPolicyNo],[AncestorCustomerKey],[PolicyKey],[PolicyNo],[CustomerKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idxNo] ON [dbo].[PolicyLineage]
(
	[AncestorPolicyNo] ASC
)
INCLUDE([CountryKey],[AncestorPolicyKey],[AncestorCustomerKey],[PolicyKey],[PolicyNo],[CustomerKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxp]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idxp] ON [dbo].[PolicyLineage]
(
	[PolicyNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
