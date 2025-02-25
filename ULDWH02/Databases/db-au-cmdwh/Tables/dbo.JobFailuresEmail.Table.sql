USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[JobFailuresEmail]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobFailuresEmail](
	[JOB_NAME] [nvarchar](300) NULL,
	[DATE_TIME] [varchar](25) NULL,
	[JOB_STEP] [varchar](10) NULL,
	[FailureEmailSentOut] [varchar](3) NULL
) ON [PRIMARY]
GO
