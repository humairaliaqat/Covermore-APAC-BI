USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblEMCApplications_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblEMCApplications_AU](
	[RecID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[CompID] [int] NULL,
	[AppTypeID] [tinyint] NULL,
	[Prod] [varchar](5) NULL,
	[AssessorID] [smallint] NULL,
	[EnteredDt] [datetime] NULL,
	[ReceivedDt] [datetime] NULL,
	[AssessedDt] [datetime] NULL,
	[SignedEndReq] [bit] NULL,
	[EndRecDt] [datetime] NULL,
	[AnnualBusPlan] [bit] NULL,
	[ProdPlan] [varchar](5) NULL,
	[DeptDt] [datetime] NULL,
	[RetDt] [datetime] NULL,
	[FileLoc] [varchar](50) NULL,
	[Claim#] [int] NULL,
	[ClaimDt] [datetime] NULL,
	[RelatedToEMC] [bit] NULL,
	[Alpha] [varchar](7) NULL,
	[AgeApproval] [char](1) NULL,
	[CreatedByID] [int] NULL,
	[Destination] [nvarchar](max) NULL,
	[FileLocDate] [datetime] NULL,
	[EnrolFormOnFile] [bit] NULL,
	[PriorityID] [tinyint] NULL,
	[TotValuePerTraveller] [money] NULL,
	[TotTravellers] [tinyint] NULL,
	[PolTypeID] [int] NULL,
	[SingMultiID] [int] NULL,
	[PolNo] [varchar](13) NULL,
	[AppliedforCover] [bit] NULL,
	[OtherInsurer] [varchar](50) NULL,
	[EDC] [datetime] NULL,
	[ExerciseRegular] [bit] NULL,
	[ExcerciseDetails] [varchar](400) NULL,
	[Epilepsy] [bit] NULL,
	[BPReading] [varchar](8) NULL,
	[BPDate] [datetime] NULL,
	[BSL] [float] NULL,
	[BSLDate] [datetime] NULL,
	[CVA_TIA] [bit] NULL,
	[Declaration] [bit] NULL,
	[Consent] [bit] NULL,
	[CaseStatusID] [int] NULL,
	[AgeDestDuration] [bit] NULL,
	[Condition] [bit] NULL,
	[SeriousCondition] [bit] NULL,
	[HeartCondition] [bit] NULL,
	[CardiacAssessmentIncluded] [bit] NULL,
	[CardiacCondMedsUnchanged] [bit] NULL,
	[AppliedForCMCover] [bit] NULL,
	[InputTypeID] [tinyint] NULL,
	[HeightUnitsID] [tinyint] NULL,
	[WeightUnitsID] [tinyint] NULL,
	[MedsChanged] [bit] NULL,
	[MedsChangedHow] [varchar](4000) NULL,
	[HasConditions] [bit] NULL,
	[DutyOfDisclosure] [bit] NULL,
	[CreatinineLevel] [float] NULL,
	[CreatinineRecordDate] [datetime] NULL,
	[Cruise] [bit] NULL,
	[ApprovalStatus] [varchar](15) NULL,
	[PenguinAreaMappingID] [int] NULL,
	[IsMultipleDestinations] [bit] NULL,
	[IsAccepted] [bit] NULL,
	[SessionToken] [varchar](150) NULL,
	[IsDeclaredByOther] [varchar](20) NULL,
	[Copyrightstatement] [varchar](750) NULL,
	[AssessmentType] [varchar](20) NULL,
	[EncrypedResult] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_tblEMCApplications_AU_ClientID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblEMCApplications_AU_ClientID] ON [dbo].[emc_EMC_tblEMCApplications_AU]
(
	[ClientID] ASC
)
INCLUDE([DeptDt],[HeightUnitsID],[WeightUnitsID],[MedsChanged],[MedsChangedHow],[CompID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
