USE [db-au-star]
GO
/****** Object:  Table [dbo].[factClaimEstimateMovement_BKP20191216_Before_Delete]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factClaimEstimateMovement_BKP20191216_Before_Delete](
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
	[EstimateGroup] [varchar](50) NULL,
	[EstimateCategory] [varchar](50) NULL,
	[PaymentEstimateMovement] [money] NOT NULL,
	[RecoveryEstimateMovement] [money] NOT NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
