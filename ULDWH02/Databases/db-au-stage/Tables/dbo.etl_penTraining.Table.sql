USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penTraining]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penTraining](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [nvarchar](4000) NULL,
	[DomainKey] [varchar](41) NULL,
	[TrainingKey] [varchar](102) NULL,
	[OutletAlphakey] [nvarchar](50) NULL,
	[UserKey] [varchar](41) NULL,
	[SurveyID] [int] NOT NULL,
	[AlphaCode] [nvarchar](25) NULL,
	[UserLogin] [nvarchar](255) NULL,
	[CourseCode] [nvarchar](255) NULL,
	[CourseName] [nvarchar](255) NULL,
	[CourseAgencyGroup] [nvarchar](255) NULL,
	[CourseCreateDate] [datetime] NOT NULL,
	[CourseStartDate] [datetime] NULL,
	[CourseEndDate] [datetime] NULL,
	[ExamStartTime] [datetime] NULL,
	[ExamFinishTime] [datetime] NULL,
	[ExamResult] [varchar](4) NOT NULL
) ON [PRIMARY]
GO
