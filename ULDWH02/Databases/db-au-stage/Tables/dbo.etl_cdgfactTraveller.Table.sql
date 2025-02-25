USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_cdgfactTraveller]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_cdgfactTraveller](
	[factTravelerID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[DOB] [datetime] NULL,
	[IsAdult] [int] NOT NULL,
	[IsChild] [int] NOT NULL,
	[IsInfant] [int] NOT NULL,
	[TreatAsAdultIndicator] [int] NOT NULL,
	[AcceptedOfferIndicator] [int] NOT NULL,
	[EMCAccepted] [int] NOT NULL,
	[Age] [int] NOT NULL,
	[FirstName] [nvarchar](20) NULL,
	[LastName] [nvarchar](20) NULL,
	[Gender] [nvarchar](1) NULL
) ON [PRIMARY]
GO
