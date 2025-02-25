USE [db-au-actuary]
GO
/****** Object:  Table [ws].[penPolicyTravellerTransaction]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[penPolicyTravellerTransaction](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTravellerTransaction_PolicyTransactionKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTravellerTransaction_PolicyTransactionKey] ON [ws].[penPolicyTravellerTransaction]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTravellerTransaction_PolicyTravellerTransactionKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTravellerTransaction_PolicyTravellerTransactionKey] ON [ws].[penPolicyTravellerTransaction]
(
	[PolicyTravellerTransactionKey] ASC,
	[PolicyTravellerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
