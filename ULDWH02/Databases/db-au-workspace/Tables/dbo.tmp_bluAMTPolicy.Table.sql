USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_bluAMTPolicy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_bluAMTPolicy](
	[DateOfSale] [datetime] NULL,
	[PolicyNumber] [nvarchar](255) NULL,
	[FirstName] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[PolicyType] [nvarchar](255) NULL,
	[SalesChannel] [nvarchar](255) NULL,
	[MonthlyOrAnnual] [nvarchar](255) NULL,
	[RecurringPayment] [nvarchar](255) NULL,
	[Underwriter] [nvarchar](255) NULL,
	[MultiTripCoverDuration] [float] NULL,
	[Affiliate] [nvarchar](255) NULL,
	[AffiliateAddress] [nvarchar](255) NULL,
	[RegulatoryStatus] [nvarchar](255) NULL,
	[SecondAffiliate] [nvarchar](255) NULL,
	[SecondAffiliateAddress] [nvarchar](255) NULL,
	[Scheme] [nvarchar](255) NULL,
	[Currency] [nvarchar](255) NULL,
	[BlueCommission] [float] NULL,
	[AffiliateCommission] [float] NULL,
	[SecondAffiliateCommission] [float] NULL,
	[Levy] [float] NULL,
	[StampDuty] [float] NULL,
	[NetPremium] [float] NULL,
	[GrossInsurancePremium] [float] NULL,
	[HandlingFee] [float] NULL,
	[PostageFee] [float] NULL,
	[SMSFee] [float] NULL,
	[NetToUW] [float] NULL,
	[InvPremiumNetOfAC] [float] NULL,
	[MethodOfPayment] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL
) ON [PRIMARY]
GO
