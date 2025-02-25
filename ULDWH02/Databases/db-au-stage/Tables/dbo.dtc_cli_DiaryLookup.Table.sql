USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_DiaryLookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_DiaryLookup](
	[DiaryLookUp_ID] [varchar](32) NOT NULL,
	[Consultant] [varchar](20) NULL,
	[StartDate] [datetime] NULL,
	[StartTime] [datetime] NULL,
	[ServiceType] [varchar](30) NULL,
	[Job_Num] [varchar](20) NULL,
	[Office] [varchar](60) NULL,
	[JobType] [varchar](50) NULL,
	[Description] [varchar](255) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[IsFirstAppt] [smallint] NULL,
	[IsEmailSent] [int] NULL,
	[IsSMSSent] [int] NULL,
	[SMSSentDate] [datetime] NULL,
	[ChangeUser] [varchar](50) NULL,
	[ChangeDate] [datetime] NULL,
	[ModeOfCounselling] [varchar](50) NULL,
	[DefaultContactNo] [varchar](20) NULL,
	[ApptDuration] [money] NULL
) ON [PRIMARY]
GO
