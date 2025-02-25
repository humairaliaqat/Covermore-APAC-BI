USE [db-au-cba-healix]
GO
/****** Object:  Table [dbo].[emcMedicalQuestions]    Script Date: 20/02/2025 3:54:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcMedicalQuestions](
	[sessionid] [varchar](max) NULL,
	[condition] [nvarchar](max) NULL,
	[ConditionID] [nvarchar](4000) NULL,
	[ConditionName] [nvarchar](4000) NULL,
	[ConditionScore] [nvarchar](4000) NULL,
	[ConditionisOkForWinterSports] [nvarchar](4000) NULL,
	[ConditionisOkForMultiTrip] [nvarchar](4000) NULL,
	[ConditionisCovered] [nvarchar](4000) NULL,
	[ConditionisExcluded] [nvarchar](4000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
