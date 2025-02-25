USE [db-au-star]
GO
/****** Object:  Table [dbo].[factClaimCount]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factClaimCount](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[UnderwritingDate] [date] NOT NULL,
	[DevelopmentDay] [bigint] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[ClaimSK] [bigint] NOT NULL,
	[ClaimEventSK] [bigint] NOT NULL,
	[BenefitSK] [bigint] NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[SectionKey] [varchar](40) NULL,
	[ClaimSizeType] [varchar](20) NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factClaimCount_BIRowID]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factClaimCount_BIRowID] ON [dbo].[factClaimCount]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factClaimCount_ClaimKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factClaimCount_ClaimKey] ON [dbo].[factClaimCount]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factClaimCount_ClaimSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factClaimCount_ClaimSK] ON [dbo].[factClaimCount]
(
	[ClaimSK] ASC
)
INCLUDE([UnderwritingDate],[DomainSK],[OutletSK],[AreaSK],[ProductSK],[ClaimEventSK],[BenefitSK],[PolicyTransactionKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
