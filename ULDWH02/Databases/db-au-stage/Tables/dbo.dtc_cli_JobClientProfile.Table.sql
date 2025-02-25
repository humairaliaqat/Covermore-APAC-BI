USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_JobClientProfile]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_JobClientProfile](
	[JobClientProfile_ID] [varchar](32) NOT NULL,
	[Job_id] [varchar](32) NULL,
	[Profile_Type] [varchar](1) NULL,
	[Question_number] [int] NULL,
	[Question] [varchar](255) NULL,
	[Answer_Type] [int] NULL,
	[Answer1] [varchar](3) NULL,
	[Answer2] [text] NULL,
	[ProfileQuestion_id] [varchar](32) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[DTC_UpdatedDate] [datetime] NULL,
	[Source] [varchar](20) NULL,
	[Source_id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
