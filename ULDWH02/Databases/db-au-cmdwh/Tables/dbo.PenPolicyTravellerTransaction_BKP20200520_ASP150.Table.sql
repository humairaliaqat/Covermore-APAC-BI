USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PenPolicyTravellerTransaction_BKP20200520_ASP150]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenPolicyTravellerTransaction_BKP20200520_ASP150](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyTravellerTransactionKey] [varchar](41) NOT NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyTravellerKey] [varchar](41) NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[PolicyTransactionID] [int] NULL,
	[PolicyTravellerID] [int] NOT NULL,
	[HasEMC] [bit] NOT NULL,
	[TripsTravellerID] [int] NULL,
	[MemberRewardFactor] [decimal](18, 2) NULL,
	[MemberRewardPointsEarned] [money] NULL
) ON [PRIMARY]
GO
