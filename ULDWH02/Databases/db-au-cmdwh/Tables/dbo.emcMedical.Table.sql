USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcMedical]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcMedical](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NULL,
	[AssessorKey] [varchar](10) NULL,
	[MedicalKey] [varchar](15) NULL,
	[ApplicationID] [int] NULL,
	[MedicalID] [int] NOT NULL,
	[GroupID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[IsMedicationsChanged] [bit] NULL,
	[HowMedicationsChanged] [varchar](4000) NULL,
	[Assessor] [varchar](50) NULL,
	[Condition] [varchar](50) NULL,
	[DiagnosisDate] [datetime] NULL,
	[ConditionStatus] [varchar](19) NULL,
	[GroupStatus] [varchar](19) NULL,
	[Medication] [varchar](2000) NULL,
	[OnlineCondition] [varchar](2000) NULL,
	[MedicalScore] [numeric](18, 2) NULL,
	[GroupScore] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedical_ApplicationKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_emcMedical_ApplicationKey] ON [dbo].[emcMedical]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedical_Conditions]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcMedical_Conditions] ON [dbo].[emcMedical]
(
	[ApplicationKey] ASC
)
INCLUDE([MedicalKey],[Condition],[ConditionStatus],[MedicalScore]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedical_GroupScore]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcMedical_GroupScore] ON [dbo].[emcMedical]
(
	[ApplicationKey] ASC,
	[ConditionStatus] ASC
)
INCLUDE([GroupID],[GroupScore],[ApplicationID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
