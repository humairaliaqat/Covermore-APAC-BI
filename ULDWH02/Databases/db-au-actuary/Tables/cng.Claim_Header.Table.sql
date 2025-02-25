USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Claim_Header]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Claim_Header](
	[Rank] [bigint] NULL,
	[DomainCountry] [varchar](2) NOT NULL,
	[Company] [varchar](5) NULL,
	[OutletKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[BasePolicyNo] [varchar](50) NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[EventID] [int] NOT NULL,
	[SectionKey] [varchar](41) NOT NULL,
	[SectionID] [int] NOT NULL,
	[CustomerCareID] [varchar](15) NOT NULL,
	[StatusAtEndOfDay] [nvarchar](100) NOT NULL,
	[StatusAtEndOfMonth] [nvarchar](100) NOT NULL,
	[AssessmentOutcome] [nvarchar](400) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[EventLocation] [nvarchar](200) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[EventSubContinent] [nvarchar](100) NULL,
	[EventContinent] [nvarchar](100) NULL,
	[CATCode] [varchar](3) NULL,
	[CatastropheShortDesc] [varchar](20) NULL,
	[CatastropheLongDesc] [nvarchar](60) NULL,
	[PerilCode] [varchar](3) NOT NULL,
	[PerilDesc] [nvarchar](65) NULL,
	[SectionCode] [varchar](25) NULL,
	[SectionDescription] [nvarchar](200) NULL,
	[BenefitLimit] [nvarchar](200) NULL,
	[BenefitSectionKey] [varchar](40) NULL,
	[BenefitCategory] [varchar](35) NULL,
	[ActuarialBenefitGroup] [varchar](19) NULL,
	[IssueQuarter] [date] NULL,
	[LossQuarter] [date] NULL,
	[ReceiptQuarter] [date] NULL,
	[RegisterQuarter] [date] NULL,
	[SectionQuarter] [date] NULL,
	[IncurredQuarter] [date] NULL,
	[IssueMonth] [date] NULL,
	[LossMonth] [date] NULL,
	[ReceiptMonth] [date] NULL,
	[RegisterMonth] [date] NULL,
	[SectionMonth] [date] NULL,
	[IncurredMonth] [date] NULL,
	[IssueDate] [date] NULL,
	[LossDate] [date] NULL,
	[ReceiptDate] [date] NULL,
	[RegisterDate] [date] NULL,
	[SectionDate] [date] NULL,
	[IncurredDate] [date] NULL,
	[IncurredTime] [datetime] NULL,
	[IncurredAgeBand] [varchar](10) NOT NULL,
	[OnlineClaimFlag] [int] NOT NULL,
	[MedicalAssistanceClaimFlag] [int] NOT NULL,
	[MentalHealthClaimFlag] [bit] NULL,
	[LuggageClaimFlag] [bit] NULL,
	[ElectronicsClaimFlag] [bit] NULL,
	[CruiseClaimFlag] [bit] NULL,
	[MopedClaimFlag] [bit] NULL,
	[RentalCarClaimFlag] [bit] NULL,
	[WinterSportClaimFlag] [bit] NULL,
	[CrimeVictimClaimFlag] [bit] NULL,
	[FoodPoisoningClaimFlag] [bit] NULL,
	[AnimalClaimFlag] [bit] NULL,
	[CFARClaimFlag] [int] NOT NULL,
	[SectionCount] [int] NULL,
	[SectionCountNonNil] [int] NULL,
	[NetPaymentMovementIncRecoveries] [decimal](38, 6) NULL,
	[NetIncurredMovementIncRecoveries] [decimal](38, 6) NULL,
	[EstimateMovement] [decimal](38, 6) NULL,
	[PaymentMovement] [decimal](38, 6) NULL,
	[RecoveryMovement] [decimal](38, 6) NULL,
	[IncurredMovement] [decimal](38, 6) NULL,
	[NetPaymentMovement] [decimal](38, 6) NULL,
	[NetRecoveryMovement] [decimal](38, 6) NULL,
	[NetIncurredMovement] [decimal](38, 6) NULL,
	[NetRealRecoveryMovement] [decimal](38, 6) NULL,
	[NetApprovedPaymentMovement] [decimal](38, 6) NULL,
	[IncurredAtReference] [decimal](38, 6) NULL,
	[NetIncurredAtReference] [decimal](38, 6) NULL,
	[IncurredAtEOM] [decimal](38, 6) NULL,
	[NetIncurredAtEOM] [decimal](38, 6) NULL,
	[MaxIncurredEOM] [decimal](38, 6) NULL,
	[MaxNetIncurredEOM] [decimal](38, 6) NULL,
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
	[FXReferenceDate] [date] NULL,
	[EstimateMovement_FX] [decimal](38, 6) NULL,
	[PaymentMovement_FX] [decimal](38, 6) NULL,
	[RecoveryMovement_FX] [decimal](38, 6) NULL,
	[IncurredMovement_FX] [decimal](38, 6) NULL,
	[NetPaymentMovement_FX] [decimal](38, 6) NULL,
	[NetRecoveryMovement_FX] [decimal](38, 6) NULL,
	[NetIncurredMovement_FX] [decimal](38, 6) NULL,
	[NetRealRecoveryMovement_FX] [decimal](38, 6) NULL,
	[NetApprovedPaymentMovement_FX] [decimal](38, 6) NULL,
	[Underwriter] [varchar](50) NULL,
	[PurchasePathGroup] [varchar](12) NULL,
	[Channel] [nvarchar](100) NULL,
	[Distributor] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[GroupName] [nvarchar](50) NULL,
	[JVCode] [nvarchar](20) NULL,
	[JV] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[AreaType] [nvarchar](50) NOT NULL,
	[AreaName] [nvarchar](150) NOT NULL,
	[Destination] [nvarchar](max) NOT NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[LeadTime] [int] NULL,
	[LeadTimeBand] [varchar](22) NULL,
	[LeadTimeGroup] [varchar](15) NULL,
	[CancellationFlag] [varchar](25) NULL,
	[CancellationCover] [money] NULL,
	[CancellationCoverBand] [varchar](8) NULL,
	[EMCFlag] [varchar](10) NULL,
	[MaxEMCScore] [decimal](18, 2) NULL,
	[TotalEMCScore] [decimal](18, 2) NULL,
	[CruiseFlag] [varchar](25) NULL,
	[ElectronicsFlag] [varchar](25) NULL,
	[LuggageFlag] [varchar](25) NULL,
	[MotorcycleFlag] [varchar](25) NULL,
	[RentalCarFlag] [varchar](25) NULL,
	[WinterSportFlag] [varchar](25) NULL,
	[CaseNote] [nvarchar](max) NULL,
	[CompletionDate] [datetime] NULL,
	[Section] [varchar](7) NOT NULL,
	[Section2] [varchar](7) NOT NULL,
	[Section3] [varchar](11) NOT NULL,
	[ClaimCount] [int] NOT NULL,
	[FinalisedTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Claim_Header_ClaimKeySectionID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_Claim_Header_ClaimKeySectionID] ON [cng].[Claim_Header]
(
	[ClaimKey] ASC,
	[SectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Claim_Header_ClaimKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_Claim_Header_ClaimKey] ON [cng].[Claim_Header]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Claim_Header_ClaimNo]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_Claim_Header_ClaimNo] ON [cng].[Claim_Header]
(
	[ClaimNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Claim_Header_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_Claim_Header_PolicyKeyProductCode] ON [cng].[Claim_Header]
(
	[PolicyKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
