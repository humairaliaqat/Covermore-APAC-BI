USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[JobFailuresPendingEmail]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobFailuresPendingEmail](
	[JOB_NAME] [nvarchar](300) NULL,
	[DATE_TIME] [date] NULL,
	[JOB_STEP] [varchar](10) NULL,
	[FailureEmailSentOut] [varchar](3) NULL
) ON [PRIMARY]
GO
