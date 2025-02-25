USE [db-au-actuary]
GO
/****** Object:  Table [ws].[ClaimIncurredMovement]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[ClaimIncurredMovement](
	[BIRowID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[StatusAtEndOfDay] [nvarchar](100) NOT NULL,
	[StatusAtEndOfMonth] [nvarchar](100) NOT NULL,
	[Currency] [varchar](3) NULL,
	[FXRate] [decimal](25, 10) NULL,
	[EstimateMovement] [decimal](20, 6) NULL,
	[PaymentMovement] [decimal](20, 6) NULL,
	[RecoveryMovement] [decimal](20, 6) NULL,
	[NetPaymentMovement] [decimal](20, 6) NULL,
	[NetRecoveryMovement] [decimal](20, 6) NULL,
	[NetRealRecoveryMovement] [decimal](20, 6) NULL,
	[NetApprovedPaymentMovement] [decimal](20, 6) NULL,
	[LocalCurrencyCode] [varchar](5) NULL,
	[ForeignCurrencyCode] [varchar](5) NULL,
	[ExposureCurrencyCode] [varchar](5) NULL,
	[ForeignCurrencyRate] [decimal](25, 10) NULL,
	[ForeignCurrencyRateDate] [date] NULL,
	[USDRate] [decimal](25, 10) NULL,
 CONSTRAINT [PK_ClaimIncurredMovement] PRIMARY KEY NONCLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [ws].[ClaimIncurredMovement]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx] ON [ws].[ClaimIncurredMovement]
(
	[ClaimKey] ASC,
	[SectionID] ASC,
	[IncurredTime] ASC
)
INCLUDE([EstimateMovement],[PaymentMovement],[RecoveryMovement],[NetPaymentMovement],[NetRecoveryMovement]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_domain]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_domain] ON [ws].[ClaimIncurredMovement]
(
	[Domain Country] ASC,
	[IncurredTime] ASC
)
INCLUDE([Company],[PolicyKey],[BasePolicyNumber],[IssueDate],[OutletKey],[ClaimKey],[ClaimNo],[PolicyNo],[PolicyIssuedDate],[ReceiptDate],[RegisterDate],[EventID],[CATCode],[EventCountryCode],[EventCountryName],[PerilCode],[LossDate],[MedicalAssistanceClaimFlag],[OnlineClaimFlag],[CustomerCareID],[SectionID],[SectionDate],[SectionCode],[BenefitSectionKey],[PaymentID],[StatusAtEndOfDay],[StatusAtEndOfMonth],[Currency],[FXRate],[EstimateMovement],[PaymentMovement],[RecoveryMovement],[NetPaymentMovement],[NetRecoveryMovement],[NetRealRecoveryMovement],[NetApprovedPaymentMovement],[LocalCurrencyCode],[ForeignCurrencyCode],[ExposureCurrencyCode],[ForeignCurrencyRate],[USDRate],[ForeignCurrencyRateDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
