USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rawspPolicyTravellerpolicytransactions_F]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rawspPolicyTravellerpolicytransactions_F](
	[PolicyKey] [varchar](41) NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[GroupCode] [nvarchar](50) NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[TransactionNumber] [varchar](50) NULL,
	[AgencyCode] [nvarchar](60) NULL,
	[StoreCode] [varchar](10) NULL,
	[ConsultantInitial] [nvarchar](50) NULL,
	[ConsultantName] [nvarchar](101) NULL,
	[MNumber] [nvarchar](200) NULL,
	[IssueTime] [datetime] NULL,
	[IssueDate] [date] NOT NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[SingleFamily] [varchar](9) NOT NULL,
	[ChildrenCount] [int] NOT NULL,
	[AdultsCount] [int] NOT NULL,
	[TravellersCount] [int] NOT NULL,
	[Duration] [int] NULL,
	[BonusDays] [int] NULL,
	[TripCost] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[Destination] [nvarchar](max) NULL,
	[Area] [nvarchar](100) NULL,
	[AreaType] [varchar](25) NULL,
	[Excess] [money] NOT NULL,
	[PolicyComment] [nvarchar](1000) NULL,
	[RentalCarPremiumCovered] [money] NULL,
	[CancellationCoverValue] [nvarchar](50) NULL,
	[UnadjustedMedicalPremium] [money] NULL,
	[UnadjustedLuggagePremium] [money] NULL,
	[UnadjustedMotorcyclePremium] [money] NULL,
	[UnadjustedRentalCarPremium] [money] NULL,
	[UnadjustedWinterSportPremium] [money] NULL,
	[UnadjustedCancellationPremium] [money] NULL,
	[UnadjustedBasePremium] [money] NULL,
	[UnadjustedNetPrice] [money] NULL,
	[UnadjustedSellPrice] [money] NULL,
	[UnadjustedCommission] [money] NULL,
	[UnadjustedAdminFee] [money] NULL,
	[CommissionRate] [numeric](15, 9) NULL,
	[NewPolicyCount] [int] NOT NULL,
	[BasePremium] [money] NULL,
	[SellPrice] [money] NULL,
	[NetPrice] [money] NULL,
	[Commission] [money] NULL,
	[GSTonGrossPremium] [money] NULL,
	[GSTOnCommission] [money] NULL,
	[SDonGrossPremium] [money] NULL,
	[SDonCommission] [money] NULL,
	[AdminFee] [money] NULL,
	[MedicalPremium] [money] NULL,
	[LuggagePremium] [money] NULL,
	[MotorcyclePremium] [money] NULL,
	[RentalCarPremium] [money] NULL,
	[WinterSportPremium] [money] NULL,
	[CancellationPremium] [money] NULL,
	[PaymentDate] [datetime] NULL,
	[PaymentMethod] [varchar](15) NOT NULL,
	[PromoCode] [nvarchar](max) NULL,
	[PostingDate] [datetime] NULL,
	[RiskNet] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
