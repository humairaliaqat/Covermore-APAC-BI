USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~ClaimIncurredMovement_20230805]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~ClaimIncurredMovement_20230805](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
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
	[USDRate] [decimal](25, 10) NULL
) ON [PRIMARY]
GO
