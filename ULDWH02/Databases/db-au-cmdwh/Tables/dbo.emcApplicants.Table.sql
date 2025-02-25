USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcApplicants]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcApplicants](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NULL,
	[ApplicantKey] [varchar](15) NOT NULL,
	[ApplicationID] [int] NULL,
	[ApplicantID] [int] NOT NULL,
	[Title] [varchar](5) NULL,
	[FirstName] [varchar](50) NULL,
	[Surname] [varchar](50) NULL,
	[Street] [varbinary](350) NULL,
	[Suburb] [varbinary](100) NULL,
	[State] [varbinary](100) NULL,
	[PostCode] [varbinary](100) NULL,
	[Phone] [varbinary](100) NULL,
	[MobilePhone] [varbinary](100) NULL,
	[Email] [varbinary](300) NULL,
	[DOB] [varbinary](100) NULL,
	[Sex] [varchar](6) NULL,
	[Height] [float] NULL,
	[HeightUnit] [varchar](20) NULL,
	[Weight] [float] NULL,
	[WeightUnit] [varchar](20) NULL,
	[EDCDate] [datetime] NULL,
	[BloodPressure] [varchar](10) NULL,
	[BloodPressureDate] [datetime] NULL,
	[BloodSugarLevel] [varchar](10) NULL,
	[BloodSugarLevelDate] [datetime] NULL,
	[CreatinineLevel] [varchar](10) NULL,
	[CreatinineRecordDate] [datetime] NULL,
	[isSmokedInLast6Months] [bit] NULL,
	[isRegularyExercise] [bit] NULL,
	[ExerciseDetails] [varchar](400) NULL,
	[HasEpilepsy] [bit] NULL,
	[HadStroke] [bit] NULL,
	[HasMedicalCondition] [bit] NULL,
	[HasSeriousCondition] [bit] NULL,
	[HasHeartCondition] [bit] NULL,
	[IsCardiacAssessmentIncluded] [bit] NULL,
	[IsCardiacUnchanged] [bit] NULL,
	[TranslatorContactID] [int] NULL,
	[TranslatorFirstName] [varchar](50) NULL,
	[TranslatorSurname] [varchar](50) NULL,
	[TranslatorRelation] [varchar](25) NULL,
	[TranslatorPhone] [varbinary](100) NULL,
	[ConsultantContactID] [int] NULL,
	[ConsultantFirstName] [varchar](50) NULL,
	[ConsultantSurname] [varchar](50) NULL,
	[ConsultantPhone] [varbinary](100) NULL,
	[ConsultantFax] [varbinary](100) NULL,
	[ConsultantEmail] [varbinary](300) NULL,
	[IsAgentConsentGiven] [bit] NULL,
	[IsEnrolmentFormOnFile] [bit] NULL,
	[AgeOfDeparture] [int] NULL,
	[ApplicantHash] [varchar](50) NULL,
	[RelaxedApplicantHash] [varchar](50) NULL,
	[CustomerID] [bigint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplicants_ApplicationKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_emcApplicants_ApplicationKey] ON [dbo].[emcApplicants]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[emcApplicants]
(
	[ApplicationKey] ASC
)
INCLUDE([RelaxedApplicantHash]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplicants_ApplicantHash]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplicants_ApplicantHash] ON [dbo].[emcApplicants]
(
	[ApplicantHash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_emcApplicants_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplicants_CustomerID] ON [dbo].[emcApplicants]
(
	[CustomerID] ASC
)
INCLUDE([RelaxedApplicantHash],[ApplicationKey],[ApplicationID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplicants_RelaxedApplicantHash]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcApplicants_RelaxedApplicantHash] ON [dbo].[emcApplicants]
(
	[RelaxedApplicantHash] ASC
)
INCLUDE([CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
