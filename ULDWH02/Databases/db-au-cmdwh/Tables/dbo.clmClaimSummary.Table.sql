USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimSummary]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimSummary](
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[FinalisedDate] [datetime] NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyKey] [varchar](55) NULL,
	[PolicyNo] [varchar](50) NULL,
	[PolicySource] [varchar](25) NULL,
	[IssuedDate] [datetime] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[Underwriter] [nvarchar](10) NULL,
	[AgencyKey] [varchar](50) NULL,
	[OutletKey] [varchar](33) NULL,
	[AgencyCode] [varchar](7) NULL,
	[AgencyName] [nvarchar](50) NULL,
	[AgencySuperGroupName] [nvarchar](25) NULL,
	[AgencyGroupName] [nvarchar](50) NULL,
	[AgencySubGroupName] [nvarchar](50) NULL,
	[AgencyGroupState] [nvarchar](50) NULL,
	[NumberOfCharged] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[NumberOfDays] [int] NULL,
	[Area] [nvarchar](100) NULL,
	[AreaType] [varchar](25) NULL,
	[Destination] [nvarchar](100) NULL,
	[TripCost] [nvarchar](50) NULL,
	[CancellationCoverValue] [nvarchar](50) NULL,
	[CancellationPremium] [money] NULL,
	[Excess] [money] NULL,
	[NameKey] [varchar](40) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[Surname] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[BusinessName] [nvarchar](100) NULL,
	[IsGroupPolicy] [bit] NULL,
	[IsLuggageClaim] [bit] NULL,
	[IsHighRisk] [bit] NULL,
	[IsOnlineClaim] [bit] NULL,
	[IsPotentialRecovery] [bit] NULL,
	[IsFinalised] [bit] NULL,
	[OnlineAlpha] [nvarchar](20) NULL,
	[OnlineConsultant] [nvarchar](50) NULL,
	[EventKey] [varchar](40) NULL,
	[EventID] [int] NULL,
	[CustomerCareID] [nvarchar](15) NULL,
	[EventDate] [datetime] NULL,
	[EventDescription] [nvarchar](100) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[Catastrophe] [nvarchar](60) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[PerilCode] [varchar](3) NULL,
	[Peril] [nvarchar](65) NULL,
	[SectionKey] [varchar](40) NULL,
	[SectionID] [int] NULL,
	[SectionCode] [varchar](25) NULL,
	[Benefit] [nvarchar](255) NULL,
	[BenefitCategory] [nvarchar](50) NULL,
	[EstimateValue] [money] NULL,
	[RecoveryEstimateValue] [money] NULL,
	[FirstEstimateDate] [datetime] NULL,
	[FirstEstimateCreator] [nvarchar](150) NULL,
	[FirstEstimateValue] [money] NULL,
	[FirstNilEstimateDate] [datetime] NULL,
	[FirstNilEstimateCreator] [nvarchar](150) NULL,
	[FirstPayment] [datetime] NULL,
	[LastPayment] [datetime] NULL,
	[PaidPayment] [money] NULL,
	[RecoveredPayment] [money] NULL,
	[PaidRecoveredPayment] [money] NULL,
	[ClaimValue] [money] NULL,
	[ApprovedPayment] [money] NULL,
	[PendingApprovalPayment] [money] NULL,
	[FailedPayment] [money] NULL,
	[StoppedPayment] [money] NULL,
	[DeclinedPayment] [money] NULL,
	[RejectedPayment] [money] NULL,
	[PendingAuthorityPayment] [money] NULL,
	[CancelledPayment] [money] NULL,
	[ReturnedPayment] [money] NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimSummary_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmClaimSummary_BIRowID] ON [dbo].[clmClaimSummary]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_AgencyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_AgencyKey] ON [dbo].[clmClaimSummary]
(
	[AgencyKey] ASC
)
INCLUDE([ClaimKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_ClaimKey] ON [dbo].[clmClaimSummary]
(
	[ClaimKey] ASC
)
INCLUDE([BenefitCategory],[FirstEstimateDate],[FirstNilEstimateDate],[EstimateValue],[RecoveryEstimateValue],[PaidPayment],[RecoveredPayment],[PaidRecoveredPayment],[ClaimValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_CustomerCareID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_CustomerCareID] ON [dbo].[clmClaimSummary]
(
	[CustomerCareID] ASC
)
INCLUDE([ClaimKey],[ClaimNo],[CreateDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_PolicyNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_PolicyNo] ON [dbo].[clmClaimSummary]
(
	[PolicyNo] ASC,
	[CountryKey] ASC
)
INCLUDE([ClaimKey],[ClaimNo],[CreateDate],[BenefitCategory],[FirstEstimateDate],[FirstNilEstimateDate],[EstimateValue],[RecoveryEstimateValue],[PaidPayment],[RecoveredPayment],[PaidRecoveredPayment],[ClaimValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_ReceivedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_ReceivedDate] ON [dbo].[clmClaimSummary]
(
	[ReceivedDate] ASC,
	[CountryKey] ASC
)
INCLUDE([ClaimKey],[BenefitCategory],[FirstEstimateDate],[FirstNilEstimateDate],[EstimateValue],[RecoveryEstimateValue],[PaidPayment],[RecoveredPayment],[PaidRecoveredPayment],[ClaimValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimSummary_SectionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimSummary_SectionKey] ON [dbo].[clmClaimSummary]
(
	[SectionKey] ASC
)
INCLUDE([ClaimKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
