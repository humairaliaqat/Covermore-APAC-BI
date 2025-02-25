USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicy]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicy](
	[FactPolicyID] [int] NOT NULL,
	[PolicyNumber] [nvarchar](40) NOT NULL,
	[SessionID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ContactID] [int] NULL,
	[CampaignID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[PolicyIssuedDateID] [int] NOT NULL,
	[PolicyIssuedTimeID] [int] NOT NULL,
	[TripStartDateID] [int] NOT NULL,
	[TripStartTimeID] [int] NOT NULL,
	[TripEndDateID] [int] NULL,
	[TripEndTimeID] [int] NULL,
	[DestCovermoreCountryListID] [int] NOT NULL,
	[DestISOCountryListID] [int] NOT NULL,
	[DestAirportsListID] [int] NULL,
	[PaymentTypeID] [int] NULL,
	[TripTypeID] [int] NULL,
	[ConstructID] [int] NULL,
	[ImpulseOfferID] [int] NULL,
	[ChargedCountryID] [int] NOT NULL,
	[PromoCodeListID] [int] NULL,
	[Excess] [int] NOT NULL,
	[MemberPointsAwarded] [int] NOT NULL,
	[HasCANX] [int] NOT NULL,
	[HasWNTS] [int] NOT NULL,
	[HasCRS] [int] NOT NULL,
	[HasLUGG] [int] NOT NULL,
	[HasRTCR] [int] NOT NULL,
	[HasEMC] [int] NOT NULL,
	[IsDiscounted] [int] NOT NULL,
	[TotalGrossPremium] [numeric](18, 2) NULL,
	[TotalDiscountedGrossPremium] [numeric](18, 2) NULL,
	[CANXCoverageAmount] [numeric](18, 2) NULL,
	[RTCRCoverageAmount] [numeric](18, 2) NULL,
	[PartnerTransactionID] [nvarchar](50) NULL,
	[ActualPaymentType] [nvarchar](10) NULL,
	[PaymentReferenceNumber] [nvarchar](50) NULL,
	[TripDuration] [int] NOT NULL,
	[DepartureCountryID] [int] NULL,
	[DepartureAirportID] [int] NULL,
	[CurrencyID] [int] NULL,
	[HasMTCL] [int] NOT NULL
) ON [PRIMARY]
GO
