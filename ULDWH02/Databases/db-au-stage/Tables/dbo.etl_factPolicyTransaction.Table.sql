USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factPolicyTransaction]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factPolicyTransaction](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicySK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[PaymentSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[PromotionSK] [int] NOT NULL,
	[TransactionTypeStatusSK] [bigint] NOT NULL,
	[IssueDate] [date] NOT NULL,
	[PostingDate] [date] NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[TransactionNumber] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[isExpo] [varchar](1) NOT NULL,
	[isPriceBeat] [varchar](1) NOT NULL,
	[isAgentSpecial] [varchar](1) NOT NULL,
	[BonusDays] [int] NULL,
	[isClientCall] [varchar](1) NOT NULL,
	[AllocationNumber] [int] NULL,
	[RiskNet] [money] NOT NULL,
	[Premium] [money] NULL,
	[BookPremium] [money] NULL,
	[SellPrice] [money] NULL,
	[NetPrice] [money] NULL,
	[PremiumSD] [money] NULL,
	[PremiumGST] [money] NULL,
	[Commission] [money] NULL,
	[CommissionSD] [money] NULL,
	[CommissionGST] [money] NULL,
	[PremiumDiscount] [money] NULL,
	[AdminFee] [money] NULL,
	[AgentPremium] [money] NULL,
	[UnadjustedSellPrice] [money] NULL,
	[UnadjustedNetPrice] [money] NULL,
	[UnadjustedCommission] [money] NULL,
	[UnadjustedAdminFee] [money] NULL,
	[PolicyCount] [int] NOT NULL,
	[AddonPolicyCount] [int] NOT NULL,
	[ExtensionPolicyCount] [int] NOT NULL,
	[CancelledPolicyCount] [int] NOT NULL,
	[CancelledTransactionCount] [int] NOT NULL,
	[CancelledAddonPolicyCount] [int] NOT NULL,
	[CANXPolicyCount] [int] NOT NULL,
	[DomesticPolicyCount] [int] NOT NULL,
	[InternationalPolicyCount] [int] NOT NULL,
	[InboundPolicyCount] [int] NOT NULL,
	[TravellersCount] [int] NOT NULL,
	[AdultsCount] [int] NOT NULL,
	[ChildrenCount] [int] NOT NULL,
	[ChargedAdultsCount] [int] NOT NULL,
	[DomesticTravellersCount] [int] NOT NULL,
	[DomesticAdultsCount] [int] NOT NULL,
	[DomesticChildrenCount] [int] NOT NULL,
	[DomesticChargedAdultsCount] [int] NOT NULL,
	[InboundTravellersCount] [int] NOT NULL,
	[InboundAdultsCount] [int] NOT NULL,
	[InboundChildrenCount] [int] NOT NULL,
	[InboundChargedAdultsCount] [int] NOT NULL,
	[InternationalTravellersCount] [int] NOT NULL,
	[InternationalAdultsCount] [int] NOT NULL,
	[InternationalChildrenCount] [int] NOT NULL,
	[InternationalChargedAdultsCount] [int] NOT NULL,
	[LuggageCount] [int] NOT NULL,
	[MedicalCount] [int] NOT NULL,
	[MotorcycleCount] [int] NOT NULL,
	[RentalCarCount] [int] NOT NULL,
	[WintersportCount] [int] NOT NULL,
	[AttachmentCount] [int] NOT NULL,
	[EMCCount] [int] NOT NULL,
	[LeadTime] [int] NULL,
	[Duration] [int] NULL,
	[CancellationCover] [money] NULL,
	[PolicyIssueDate] [datetime] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[UnderwriterCode] [varchar](100) NULL,
	[DepartureDateSK] [date] NULL,
	[ReturnDateSK] [date] NULL,
	[IssueDateSK] [date] NULL,
	[AddonGroups] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
