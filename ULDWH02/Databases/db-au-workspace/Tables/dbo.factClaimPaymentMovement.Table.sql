USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factClaimPaymentMovement]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factClaimPaymentMovement](
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
	[SectionKey] [varchar](40) NOT NULL,
	[ClaimSizeType] [varchar](20) NULL,
	[PaymentKey] [varchar](40) NOT NULL,
	[PaymentStatus] [varchar](4) NULL,
	[PaymentType] [varchar](10) NULL,
	[PaymentMovement] [money] NOT NULL,
	[RecoveryMovement] [money] NOT NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
