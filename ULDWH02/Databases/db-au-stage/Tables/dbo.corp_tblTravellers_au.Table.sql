USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblTravellers_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblTravellers_au](
	[TravellerID] [int] NOT NULL,
	[RegistrationID] [int] NOT NULL,
	[Title] [varchar](10) NULL,
	[FirstName] [varchar](200) NULL,
	[SurName] [varchar](200) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[isPrimary] [bit] NULL,
	[isAdult] [bit] NULL
) ON [PRIMARY]
GO
