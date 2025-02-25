USE [db-au-cba-healix]
GO
/****** Object:  Table [dbo].[emcHealix]    Script Date: 20/02/2025 3:54:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcHealix](
	[SessionID] [varchar](max) NULL,
	[AssessmentDatePosixTimestamp] [bigint] NULL,
	[AssessmentDateUTC] [datetime] NULL,
	[AssessmentDateAusLocalTime] [datetime] NULL,
	[DOB] [datetime] NULL,
	[FirstName] [varchar](max) NULL,
	[LastName] [varchar](max) NULL,
	[impulse_response] [varchar](max) NULL,
	[verisk_response] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
