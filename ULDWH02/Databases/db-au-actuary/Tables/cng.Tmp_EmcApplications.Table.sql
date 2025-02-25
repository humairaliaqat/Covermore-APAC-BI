USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_EmcApplications]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_EmcApplications](
	[QuoteKey] [int] NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NOT NULL,
	[CompanyKey] [varchar](10) NULL,
	[AgencyKey] [varchar](10) NULL,
	[OutletAlphaKey] [varchar](33) NULL,
	[AssessorKey] [varchar](10) NULL,
	[CreatorKey] [varchar](10) NULL,
	[ApplicationID] [int] NOT NULL,
	[RecordID] [int] NOT NULL,
	[ApplicationType] [varchar](25) NULL,
	[AgencyCode] [varchar](7) NULL,
	[AssessorID] [int] NULL,
	[Assessor] [varchar](50) NULL,
	[CreatorID] [int] NULL,
	[Creator] [varchar](50) NULL,
	[Priority] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[ReceiveDate] [datetime] NULL,
	[AssessedDate] [datetime] NULL,
	[IsEndorsementSigned] [bit] NULL,
	[EndorsementDate] [datetime] NULL,
	[ApplicationStatus] [varchar](25) NULL,
	[ApprovalStatus] [varchar](15) NULL,
	[AgeApprovalStatus] [varchar](15) NULL,
	[MedicalRisk] [decimal](18, 2) NULL,
	[AreaName] [varchar](100) NULL,
	[AreaCode] [varchar](50) NULL,
	[ScreeningVersion] [varchar](10) NULL,
	[PlanCode] [varchar](50) NULL,
	[ProductType] [varchar](100) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[TripDuration] [int] NULL,
	[Destination] [varchar](max) NULL,
	[TravellerCount] [int] NULL,
	[ValuePerTraveller] [decimal](18, 2) NULL,
	[TripType] [varchar](20) NULL,
	[PolicyNo] [varchar](50) NULL,
	[OtherInsurer] [varchar](50) NULL,
	[InputType] [varchar](10) NULL,
	[FileLocation] [varchar](50) NULL,
	[FileLocationDate] [datetime] NULL,
	[ClaimNo] [int] NULL,
	[ClaimDate] [datetime] NULL,
	[IsClaimRelatedToEMC] [bit] NULL,
	[IsDeclarationSigned] [bit] NULL,
	[IsAnnualBusinessPlan] [bit] NULL,
	[IsApplyingForEMCCover] [bit] NULL,
	[IsApplyingForCMCover] [bit] NULL,
	[IsSendOutcomeByEmail] [bit] NULL,
	[HasAgeDestinationDuration] [bit] NULL,
	[IsDutyOfDisclosure] [bit] NULL,
	[IsCruise] [bit] NULL,
	[IsAnnualMultiTrip] [bit] NULL,
	[IsWinterSport] [bit] NULL,
	[IsOnlineAssessment] [bit] NULL,
	[OnlineAssessment] [varchar](max) NULL,
	[EMCPremium] [decimal](18, 2) NOT NULL,
	[AgePremium] [decimal](18, 2) NOT NULL,
	[Excess] [decimal](18, 2) NOT NULL,
	[GeneralLimit] [decimal](18, 2) NOT NULL,
	[PaymentDuration] [varchar](15) NULL,
	[RestrictedConditions] [varchar](255) NULL,
	[OtherRestrictions] [varchar](255) NULL,
	[PaymentComments] [varchar](4096) NULL,
	[IsAwaitingMedicalReview] [bit] NULL,
	[HasBeenTreatedLast12Months] [bit] NULL,
	[HasVisitedDoctorLast90Days] [bit] NULL,
	[IsSeekingMedicalOverseas] [bit] NULL,
	[IsTravellingAgainstMedicalAdvice] [bit] NULL,
	[HasDiagnosedTerminalCondition] [bit] NULL,
	[HasReceviedAdviceTerminalCondition] [bit] NULL,
	[MedicalTotalCount] [int] NULL,
	[MedicalApprovedCount] [int] NULL,
	[MedicalAutoAcceptCount] [int] NULL,
	[MedicalDeniedCount] [int] NULL,
	[MedicalAwaitingAssessmentCount] [int] NULL,
	[MedicalNotAssessedCount] [int] NULL,
	[CreateDateOnly] [date] NULL,
	[AssessedDateOnly] [date] NULL,
	[IsMultipleDestinations] [bit] NULL,
	[IsAccepted] [bit] NULL,
	[Conditions] [nvarchar](max) NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[JV] [nvarchar](55) NULL,
	[PolicyTravellerTransactionKey] [varchar](41) NULL,
	[PolicyTravellerKey] [varchar](41) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[BasePolicyNumber] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[IssueTime] [datetime] NULL,
	[PolicyOutletAlphaKey] [nvarchar](50) NULL,
	[PolicySuperGroupName] [nvarchar](25) NULL,
	[PolicyJV] [nvarchar](55) NULL,
	[PremiumIncrease] [numeric](18, 5) NULL,
	[EMCGrossPremium] [money] NULL,
	[EMCApproved] [varchar](15) NULL,
	[PolicyPurchased] [varchar](21) NOT NULL,
	[EMCAccepted] [varchar](30) NOT NULL,
	[Rank] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_EmcApplications_ApplicationKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_EmcApplications_ApplicationKey] ON [cng].[Tmp_EmcApplications]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
