USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_factTraveler_AU_AG_Temp]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_factTraveler_AU_AG_Temp](
	[FactTravelerID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[BirthDateDimDateID] [int] NULL,
	[IsAdult] [int] NOT NULL,
	[IsChild] [int] NOT NULL,
	[IsInfant] [int] NOT NULL,
	[IsPrimary] [int] NOT NULL,
	[TreatAsAdultIndicator] [int] NOT NULL,
	[AcceptedOfferIndicator] [int] NOT NULL,
	[EMCAccepted] [int] NOT NULL,
	[Age] [int] NOT NULL,
	[FirstName] [nvarchar](20) NULL,
	[LastName] [nvarchar](20) NULL,
	[Gender] [nvarchar](1) NULL
) ON [PRIMARY]
GO
