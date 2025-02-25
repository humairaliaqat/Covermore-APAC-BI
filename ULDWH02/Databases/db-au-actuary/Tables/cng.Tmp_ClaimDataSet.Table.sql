USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_ClaimDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_ClaimDataSet](
	[Domain Country] [varchar](2) NOT NULL,
	[Company] [varchar](5) NULL,
	[OutletKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[BasePolicyNo] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[IssueMonth] [date] NULL,
	[IssueQuarter] [datetime] NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[ReceiptDate] [date] NULL,
	[ReceiptMonth] [date] NULL,
	[ReceiptQuarter] [datetime] NULL,
	[RegisterDate] [date] NULL,
	[RegisterMonth] [date] NULL,
	[RegisterQuarter] [datetime] NULL,
	[EventID] [int] NOT NULL,
	[LossDate] [date] NULL,
	[LossMonth] [date] NULL,
	[LossQuarter] [datetime] NULL,
	[CATCode] [varchar](3) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[PerilCode] [varchar](3) NOT NULL,
	[MedicalAssistanceClaimFlag] [int] NOT NULL,
	[OnlineClaimFlag] [int] NOT NULL,
	[CustomerCareID] [varchar](15) NOT NULL,
	[SectionID] [int] NOT NULL,
	[SectionDate] [date] NULL,
	[SectionMonth] [date] NULL,
	[SectionQuarter] [datetime] NULL,
	[SectionCode] [varchar](25) NULL,
	[BenefitSectionKey] [varchar](40) NULL,
	[PaymentID] [int] NULL,
	[IncurredTime] [datetime] NULL,
	[IncurredDate] [date] NULL,
	[IncurredMonth] [date] NULL,
	[IncurredQuarter] [datetime] NULL,
	[IncurredAgeBand] [varchar](10) NOT NULL,
	[ReceiptDevelopmentMonth] [int] NULL,
	[IssueDevelopmentMonth] [int] NULL,
	[LossDevelopmentMonth] [int] NULL,
	[ReceiptDevelopmentQuarter] [int] NULL,
	[IssueDevelopmentQuarter] [int] NULL,
	[LossDevelopmentQuarter] [int] NULL,
	[StatusAtEndOfDay] [nvarchar](100) NOT NULL,
	[StatusAtEndOfMonth] [nvarchar](100) NOT NULL,
	[EstimateMovement] [decimal](38, 6) NULL,
	[PaymentMovement] [decimal](38, 6) NULL,
	[RecoveryMovement] [decimal](38, 6) NULL,
	[IncurredMovement] [decimal](38, 6) NULL,
	[NetPaymentMovement] [decimal](38, 6) NULL,
	[NetRecoveryMovement] [decimal](38, 6) NULL,
	[NetIncurredMovement] [decimal](38, 6) NULL,
	[NetRealRecoveryMovement] [decimal](38, 6) NULL,
	[NetApprovedPaymentMovement] [decimal](38, 6) NULL,
	[LocalCurrencyCode] [varchar](5) NULL,
	[OriginalCurrencyCode] [varchar](3) NULL,
	[OriginalFXRate] [decimal](25, 10) NULL,
	[ForeignCurrencyCode] [varchar](5) NULL,
	[ExposureCurrencyCode] [varchar](5) NULL,
	[ForeignCurrencyRate] [decimal](25, 10) NULL,
	[USDRate] [decimal](25, 10) NULL,
	[ForeignCurrencyRateDate] [date] NULL,
	[AssessmentOutcome] [nvarchar](400) NULL,
	[BIRowID] [bigint] NOT NULL,
	[SectionCount] [int] NULL,
	[IncurredAtReference] [decimal](38, 6) NULL,
	[NetIncurredAtReference] [decimal](38, 6) NULL,
	[IncurredAtEOM] [decimal](38, 6) NULL,
	[NetIncurredAtEOM] [decimal](38, 6) NULL,
	[MaxIncurredEOM] [decimal](38, 6) NULL,
	[MaxNetIncurredEOM] [decimal](38, 6) NULL,
	[FXReferenceDate] [date] NULL,
	[FXReferenceRate] [decimal](25, 10) NULL,
	[USDRateReference] [decimal](25, 10) NULL,
	[FXConversion] [decimal](38, 13) NULL,
	[UsedFXCode] [varchar](5) NULL,
	[UsedFXRateThen] [decimal](25, 10) NULL,
	[UsedFXRateNow] [decimal](25, 10) NULL,
	[EstimateAsAt] [decimal](38, 6) NULL,
	[PaymentAsAt] [decimal](38, 6) NULL,
	[RecoveryAsAt] [decimal](38, 6) NULL,
	[IncurredAsAt] [decimal](38, 6) NULL,
	[NetPaymentAsAt] [decimal](38, 6) NULL,
	[NetRecoveryAsAt] [decimal](38, 6) NULL,
	[NetIncurredAsAt] [decimal](38, 6) NULL,
	[NetRealRecoveryAsAt] [decimal](38, 6) NULL,
	[NetApprovedPaymentAsAt] [decimal](38, 6) NULL,
	[EstimateAsAt_FX] [decimal](38, 6) NULL,
	[PaymentAsAt_FX] [decimal](38, 6) NULL,
	[RecoveryAsAt_FX] [decimal](38, 6) NULL,
	[IncurredAsAt_FX] [decimal](38, 6) NULL,
	[NetPaymentAsAt_FX] [decimal](38, 6) NULL,
	[NetRecoveryAsAt_FX] [decimal](38, 6) NULL,
	[NetIncurredAsAt_FX] [decimal](38, 6) NULL,
	[NetRealRecoveryAsAt_FX] [decimal](38, 6) NULL,
	[NetApprovedPaymentAsAt_FX] [decimal](38, 6) NULL,
	[EstimateMovement_FX] [decimal](38, 6) NULL,
	[PaymentMovement_FX] [decimal](38, 6) NULL,
	[RecoveryMovement_FX] [decimal](38, 6) NULL,
	[IncurredMovement_FX] [decimal](38, 6) NULL,
	[NetPaymentMovement_FX] [decimal](38, 6) NULL,
	[NetRecoveryMovement_FX] [decimal](38, 6) NULL,
	[NetIncurredMovement_FX] [decimal](38, 6) NULL,
	[NetRealRecoveryMovment_FX] [decimal](38, 6) NULL,
	[NetApprovedPaymentMovement_FX] [decimal](38, 6) NULL,
	[BenefitCategory] [varchar](35) NULL,
	[ActuarialBenefitGroup] [varchar](19) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[ClaimMentalHealthFlag] [bit] NULL,
	[ClaimLuggageFlag] [bit] NULL,
	[ClaimElectronicsFlag] [bit] NULL,
	[ClaimCruiseFlag] [bit] NULL,
	[ClaimMopedFlag] [bit] NULL,
	[ClaimRentalCarFlag] [bit] NULL,
	[ClaimWinterSportFlag] [bit] NULL,
	[ClaimCrimeVictimFlag] [bit] NULL,
	[ClaimFoodPoisoningFlag] [bit] NULL,
	[ClaimAnimalFlag] [bit] NULL,
	[PurchasePathGroup] [varchar](12) NULL,
	[LeadTime] [int] NULL,
	[LeadTimeBand] [varchar](22) NULL,
	[LeadTimeGroup] [varchar](15) NULL,
	[CancellationCover] [money] NULL,
	[CancellationCoverBand] [varchar](8) NULL,
	[EMCFlag] [varchar](10) NULL,
	[MaxEMCScore] [decimal](18, 2) NULL,
	[TotalEMCScore] [decimal](18, 2) NULL,
	[CancellationFlag] [varchar](25) NULL,
	[CruiseFlag] [varchar](25) NULL,
	[ElectronicsFlag] [varchar](25) NULL,
	[LuggageFlag] [varchar](25) NULL,
	[MotorcycleFlag] [varchar](25) NULL,
	[RentalCarFlag] [varchar](25) NULL,
	[WinterSportFlag] [varchar](25) NULL,
	[EventSubContinent] [nvarchar](100) NULL,
	[EventContinent] [nvarchar](100) NULL,
	[Distributor] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[GroupName] [nvarchar](50) NULL,
	[Channel] [nvarchar](100) NULL,
	[JVCode] [nvarchar](20) NULL,
	[JV] [nvarchar](100) NULL,
	[AreaName] [nvarchar](150) NOT NULL,
	[AreaType] [nvarchar](50) NOT NULL,
	[Destination] [nvarchar](max) NOT NULL,
	[ProductCode] [nvarchar](50) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[NumberOfRecords] [int] NOT NULL,
	[NetPaymentMovementIncRecoveries] [decimal](38, 6) NULL,
	[NetIncurredMovementIncRecoveries] [decimal](38, 6) NULL,
	[IncurredACS] [int] NOT NULL,
	[SizeAsAt] [varchar](18) NOT NULL,
	[Size500] [varchar](10) NOT NULL,
	[Size1k] [varchar](10) NOT NULL,
	[Size5k] [varchar](10) NOT NULL,
	[Size10k] [varchar](10) NOT NULL,
	[Size25k] [varchar](10) NOT NULL,
	[Size35k] [varchar](10) NOT NULL,
	[Size50k] [varchar](10) NOT NULL,
	[Size75k] [varchar](10) NOT NULL,
	[Size100k] [varchar](10) NOT NULL,
	[Underwriter] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ClaimDataSet_ClaimKeySectionID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_ClaimDataSet_ClaimKeySectionID] ON [cng].[Tmp_ClaimDataSet]
(
	[ClaimKey] ASC,
	[SectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ClaimDataSet_ClaimKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_ClaimDataSet_ClaimKey] ON [cng].[Tmp_ClaimDataSet]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_ClaimDataSet_ClaimNo]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_ClaimDataSet_ClaimNo] ON [cng].[Tmp_ClaimDataSet]
(
	[ClaimNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ClaimDataSet_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_ClaimDataSet_PolicyKeyProductCode] ON [cng].[Tmp_ClaimDataSet]
(
	[PolicyKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
