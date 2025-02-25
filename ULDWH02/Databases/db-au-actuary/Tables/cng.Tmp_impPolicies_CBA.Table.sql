USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_impPolicies_CBA]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_impPolicies_CBA](
	[BIRowID] [bigint] NOT NULL,
	[ImpulsePolicyID] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PolicyKey] [varchar](41) NULL,
	[ImpulsePolicyQuoteID] [varchar](50) NULL,
	[QuoteSK] [bigint] NULL,
	[QuoteID] [varchar](50) NULL,
	[QuoteSource] [nvarchar](50) NULL,
	[cbaChannelID] [nvarchar](50) NULL,
	[ProductCode] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicies_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_impPolicies_PolicyKeyProductCode] ON [cng].[Tmp_impPolicies_CBA]
(
	[PolicyKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
