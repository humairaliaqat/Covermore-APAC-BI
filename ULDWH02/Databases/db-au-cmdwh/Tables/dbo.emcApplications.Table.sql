USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcApplications]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcApplications](
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
	[ProductCode] [varchar](3) NULL,
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
	[IsAccepted] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_emcApplications_AssessedDateOnly]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_emcApplications_AssessedDateOnly] ON [dbo].[emcApplications]
(
	[AssessedDateOnly] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[emcApplications]
(
	[ApplicationKey] ASC
)
INCLUDE([ApplicationID],[AssessedDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplications_ApplicationID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplications_ApplicationID] ON [dbo].[emcApplications]
(
	[ApplicationID] ASC,
	[CountryKey] ASC
)
INCLUDE([ApplicationType],[MedicalRisk]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplications_ApplicationKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplications_ApplicationKey] ON [dbo].[emcApplications]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplications_AssessedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplications_AssessedDate] ON [dbo].[emcApplications]
(
	[AssessedDate] ASC,
	[CountryKey] ASC
)
INCLUDE([ApplicationKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_emcApplications_TravelDates]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplications_TravelDates] ON [dbo].[emcApplications]
(
	[DepartureDate] ASC,
	[ReturnDate] ASC
)
INCLUDE([ApplicationKey],[ApplicationID],[AssessedDateOnly],[AreaName],[MedicalRisk]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
