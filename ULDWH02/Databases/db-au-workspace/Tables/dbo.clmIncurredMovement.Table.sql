USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmIncurredMovement]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmIncurredMovement](
	[Domain Country] [varchar](2) NOT NULL,
	[Company] [varchar](5) NULL,
	[PolicyKey] [varchar](41) NULL,
	[BasePolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[OutletKey] [varchar](41) NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[TRIPSPolicyKey] [varchar](55) NULL,
	[PenguinTransKey] [varchar](41) NULL,
	[ClaimAlpha] [varchar](7) NULL,
	[ClaimNo] [int] NOT NULL,
	[PolicyNo] [varchar](50) NULL,
	[PolicyIssuedDate] [datetime] NULL,
	[ClaimProduct] [varchar](4) NULL,
	[ReceiptDate] [datetime] NULL,
	[RegisterDate] [datetime] NULL,
	[EventID] [int] NOT NULL,
	[CATCode] [varchar](3) NOT NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[PerilCode] [varchar](3) NOT NULL,
	[LossDate] [datetime] NULL,
	[MedicalAssistanceClaimFlag] [int] NOT NULL,
	[OnlineClaimFlag] [int] NOT NULL,
	[CustomerCareID] [varchar](15) NOT NULL,
	[SectionID] [int] NULL,
	[SectionDate] [datetime] NULL,
	[SectionCode] [varchar](25) NULL,
	[BenefitSectionKey] [varchar](40) NULL,
	[PaymentID] [int] NULL,
	[IncurredTime] [datetime] NULL,
	[StatusAtIncurredTime] [nvarchar](100) NOT NULL,
	[Currency] [varchar](3) NULL,
	[FXRate] [float] NULL,
	[EstimateMovement] [money] NULL,
	[PaymentMovement] [money] NULL,
	[RecoveryMovement] [money] NULL,
	[NetPaymentMovement] [real] NULL,
	[NetRecoveryMovement] [real] NULL,
	[NetRealRecoveryMovement] [real] NULL,
	[NetApprovedPaymentMovement] [real] NULL,
	[LocalCurrencyCode] [varchar](5) NULL,
	[ForeignCurrencyCode] [varchar](5) NULL,
	[ExposureCurrencyCode] [varchar](5) NULL,
	[ForeignCurrencyRate] [decimal](25, 10) NULL,
	[ForeignCurrencyRateDate] [date] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[clmIncurredMovement]
(
	[Domain Country] ASC,
	[CATCode] ASC,
	[IncurredTime] ASC,
	[SectionCode] ASC
)
INCLUDE([EstimateMovement]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cl]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cl] ON [dbo].[clmIncurredMovement]
(
	[ClaimKey] ASC,
	[IncurredTime] DESC
)
INCLUDE([StatusAtIncurredTime],[RegisterDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
