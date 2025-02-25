USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpTravellers]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpTravellers](
	[CountryKey] [varchar](2) NOT NULL,
	[TravellerKey] [varchar](33) NULL,
	[RegistrationKey] [varchar](33) NULL,
	[TravellerID] [int] NOT NULL,
	[RegistrationID] [int] NOT NULL,
	[Title] [varchar](10) NULL,
	[FirstName] [varchar](200) NULL,
	[Surname] [varchar](200) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[isPrimary] [bit] NULL,
	[isAdult] [bit] NULL,
	[EMCID] [int] NULL,
	[EMCIssuedDate] [datetime] NULL,
	[EMCAssessmentNo] [varchar](50) NULL,
	[EMCLoad] [money] NULL,
	[EMCAccept] [bit] NULL,
	[ClosingID] [int] NULL,
	[ClosingIssuedDate] [datetime] NULL,
	[ClosingLoad] [money] NULL,
	[ClosingAccept] [bit] NULL,
	[ClosingExtraDays] [int] NULL,
	[FreeDaysID] [int] NULL,
	[FreeDays] [int] NULL,
	[FreeDaysLoad] [money] NULL,
	[FreeDaysIssuedDate] [datetime] NULL
) ON [PRIMARY]
GO
