USE [db-au-star]
GO
/****** Object:  Table [dbo].[factPolicyTransactionAddons]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTransactionAddons](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicySK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[PromotionSK] [int] NOT NULL,
	[LeadTime] [int] NOT NULL,
	[PolicyTransactionKey] [nvarchar](50) NULL,
	[AddonGroup] [nvarchar](50) NOT NULL,
	[AddonCount] [int] NULL,
	[SellPrice] [decimal](15, 2) NULL,
	[UnadjustedSellPrice] [decimal](15, 2) NULL,
	[PolicyIssueDate] [date] NULL,
	[DepartureDate] [date] NULL,
	[ReturnDate] [date] NULL,
	[UnderwriterCode] [varchar](100) NULL,
	[DepartureDateSK] [date] NULL,
	[ReturnDateSK] [date] NULL,
	[IssueDateSK] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factPolicyTransactionAddons_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransactionAddons_DateSK] ON [dbo].[factPolicyTransactionAddons]
(
	[DateSK] ASC,
	[DomainSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factPolicyTransactionAddons_PolicySK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransactionAddons_PolicySK] ON [dbo].[factPolicyTransactionAddons]
(
	[PolicySK] ASC,
	[AddonGroup] ASC
)
INCLUDE([AddonCount],[SellPrice],[UnadjustedSellPrice]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factPolicyTransactionAddons_PolicyTransactionKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransactionAddons_PolicyTransactionKey] ON [dbo].[factPolicyTransactionAddons]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ccsi_factPolicyTransactionAddons]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED COLUMNSTORE INDEX [ccsi_factPolicyTransactionAddons] ON [dbo].[factPolicyTransactionAddons] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
