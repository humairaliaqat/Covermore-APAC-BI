USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penTraining]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penTraining](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NULL,
	[TrainingKey] [varchar](20) NOT NULL,
	[OutletAlphakey] [nvarchar](50) NULL,
	[UserKey] [varchar](41) NULL,
	[SurveyID] [int] NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[UserLogin] [nvarchar](50) NULL,
	[CourseCode] [nvarchar](255) NULL,
	[CourseName] [nvarchar](255) NULL,
	[CourseAgencyGroup] [varchar](5) NULL,
	[CourseCreateDate] [datetime] NULL,
	[CourseStartDate] [datetime] NULL,
	[CourseEndDate] [datetime] NULL,
	[ExamStartTime] [datetime] NULL,
	[ExamFinishTime] [datetime] NULL,
	[ExamResult] [varchar](4) NOT NULL,
	[DomainKey] [varchar](41) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTraining_TrainingKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penTraining_TrainingKey] ON [dbo].[penTraining]
(
	[TrainingKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penTraining_ExamTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTraining_ExamTime] ON [dbo].[penTraining]
(
	[ExamStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTraining_OutletAlphakey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTraining_OutletAlphakey] ON [dbo].[penTraining]
(
	[OutletAlphakey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTraining_UserKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTraining_UserKey] ON [dbo].[penTraining]
(
	[UserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
