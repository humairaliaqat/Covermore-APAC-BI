USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransSummary_20200806]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransSummary_20200806](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNoKey] [varchar](100) NULL,
	[UserKey] [varchar](41) NULL,
	[UserSKey] [bigint] NULL,
	[PolicyTransactionID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[TransactionTypeID] [int] NOT NULL,
	[TransactionType] [varchar](50) NULL,
	[IssueDate] [date] NOT NULL,
	[AccountingPeriod] [datetime] NOT NULL,
	[CRMUserID] [int] NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[TransactionStatusID] [int] NOT NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[Transferred] [bit] NOT NULL,
	[UserComments] [nvarchar](1000) NULL,
	[CommissionTier] [varchar](50) NULL,
	[VolumeCommission] [numeric](18, 9) NULL,
	[Discount] [numeric](18, 9) NULL,
	[isExpo] [bit] NOT NULL,
	[isPriceBeat] [bit] NOT NULL,
	[NoOfBonusDaysApplied] [int] NULL,
	[isAgentSpecial] [bit] NOT NULL,
	[ParentID] [int] NULL,
	[ConsultantID] [int] NULL,
	[isClientCall] [bit] NULL,
	[RiskNet] [money] NULL,
	[AutoComments] [nvarchar](2000) NULL,
	[TripCost] [nvarchar](50) NULL,
	[AllocationNumber] [int] NULL,
	[PaymentDate] [datetime] NULL,
	[TransactionStart] [datetime] NULL,
	[TransactionEnd] [datetime] NULL,
	[TaxAmountSD] [money] NULL,
	[TaxOnAgentCommissionSD] [money] NULL,
	[TaxAmountGST] [money] NULL,
	[TaxOnAgentCommissionGST] [money] NULL,
	[BasePremium] [money] NULL,
	[GrossPremium] [money] NULL,
	[Commission] [money] NULL,
	[DiscountPolicyTrans] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[AdjustedNet] [money] NULL,
	[CommissionRatePolicyPrice] [numeric](15, 9) NULL,
	[DiscountRatePolicyPrice] [numeric](15, 9) NULL,
	[CommissionRateTravellerPrice] [numeric](15, 9) NULL,
	[DiscountRateTravellerPrice] [numeric](15, 9) NULL,
	[CommissionRateTravellerAddOnPrice] [numeric](15, 9) NULL,
	[DiscountRateTravellerAddOnPrice] [numeric](15, 9) NULL,
	[CommissionRateEMCPrice] [numeric](15, 9) NULL,
	[DiscountRateEMCPrice] [numeric](15, 9) NULL,
	[UnAdjBasePremium] [money] NULL,
	[UnAdjGrossPremium] [money] NULL,
	[UnAdjCommission] [money] NULL,
	[UnAdjDiscountPolicyTrans] [money] NULL,
	[UnAdjGrossAdminFee] [money] NULL,
	[UnAdjAdjustedNet] [money] NULL,
	[UnAdjCommissionRatePolicyPrice] [numeric](15, 9) NULL,
	[UnAdjDiscountRatePolicyPrice] [numeric](15, 9) NULL,
	[UnAdjCommissionRateTravellerPrice] [numeric](15, 9) NULL,
	[UnAdjDiscountRateTravellerPrice] [numeric](15, 9) NULL,
	[UnAdjCommissionRateTravellerAddOnPrice] [numeric](15, 9) NULL,
	[UnAdjDiscountRateTravellerAddOnPrice] [numeric](15, 9) NULL,
	[UnAdjCommissionRateEMCPrice] [numeric](15, 9) NULL,
	[UnAdjDiscountRateEMCPrice] [numeric](15, 9) NULL,
	[StoreCode] [varchar](10) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[OutletSKey] [bigint] NULL,
	[NewPolicyCount] [int] NOT NULL,
	[BasePolicyCount] [int] NOT NULL,
	[AddonPolicyCount] [int] NOT NULL,
	[ExtensionPolicyCount] [int] NOT NULL,
	[CancelledPolicyCount] [int] NOT NULL,
	[CancelledAddonPolicyCount] [int] NOT NULL,
	[CANXPolicyCount] [int] NOT NULL,
	[DomesticPolicyCount] [int] NOT NULL,
	[InternationalPolicyCount] [int] NOT NULL,
	[TravellersCount] [int] NOT NULL,
	[AdultsCount] [int] NOT NULL,
	[ChildrenCount] [int] NOT NULL,
	[ChargedAdultsCount] [int] NOT NULL,
	[DomesticTravellersCount] [int] NOT NULL,
	[DomesticAdultsCount] [int] NOT NULL,
	[DomesticChildrenCount] [int] NOT NULL,
	[DomesticChargedAdultsCount] [int] NOT NULL,
	[InternationalTravellersCount] [int] NOT NULL,
	[InternationalAdultsCount] [int] NOT NULL,
	[InternationalChildrenCount] [int] NOT NULL,
	[InternationalChargedAdultsCount] [int] NOT NULL,
	[NumberofDays] [int] NOT NULL,
	[LuggageCount] [int] NOT NULL,
	[MedicalCount] [int] NOT NULL,
	[MotorcycleCount] [int] NOT NULL,
	[RentalCarCount] [int] NOT NULL,
	[WintersportCount] [int] NOT NULL,
	[AttachmentCount] [int] NOT NULL,
	[EMCCount] [int] NOT NULL,
	[InternationalNewPolicyCount] [int] NOT NULL,
	[InternationalCANXPolicyCount] [int] NOT NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[SingleFamilyFlag] [int] NULL,
	[isAMT] [bit] NULL,
	[IssueTime] [datetime] NULL,
	[ExternalReference] [nvarchar](100) NULL,
	[UnAdjTaxAmountSD] [money] NULL,
	[UnAdjTaxOnAgentCommissionSD] [money] NULL,
	[UnAdjTaxAmountGST] [money] NULL,
	[UnAdjTaxOnAgentCommissionGST] [money] NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[IssueTimeUTC] [datetime] NULL,
	[PaymentDateUTC] [datetime] NULL,
	[TransactionStartUTC] [datetime] NULL,
	[TransactionEndUTC] [datetime] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[CurrencySymbol] [varchar](10) NULL,
	[YAGOIssueDate] [date] NULL,
	[InboundPolicyCount] [int] NOT NULL,
	[InboundTravellersCount] [int] NOT NULL,
	[InboundAdultsCount] [int] NOT NULL,
	[InboundChildrenCount] [int] NOT NULL,
	[InboundChargedAdultsCount] [int] NOT NULL,
	[ImportDate] [datetime] NULL,
	[PostingDate] [datetime] NULL,
	[YAGOPostingDate] [date] NULL,
	[PostingTime] [datetime] NULL,
	[CompetitorName] [nvarchar](50) NULL,
	[CompetitorPrice] [money] NULL,
	[CanxCover] [int] NULL,
	[PaymentMode] [nvarchar](20) NULL,
	[PointsRedeemed] [money] NULL,
	[RedemptionReference] [nvarchar](255) NULL,
	[GigyaId] [nvarchar](300) NULL,
	[IssuingConsultantID] [int] NULL,
	[LeadTimeDate] [date] NULL,
	[MaxAMTDuration] [int] NULL,
	[RefundTransactionID] [int] NULL,
	[RefundTransactionKey] [varchar](41) NULL,
	[TopUp] [bit] NULL,
	[RefundToCustomer] [bit] NULL,
	[CNStatusID] [int] NULL
) ON [PRIMARY]
GO
