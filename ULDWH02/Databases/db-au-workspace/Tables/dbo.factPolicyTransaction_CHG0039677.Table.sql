USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyTransaction_CHG0039677]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTransaction_CHG0039677](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
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
	[IssueDate] [datetime] NULL,
	[PostingDate] [datetime] NULL,
	[PolicyTransactionKey] [nvarchar](50) NULL,
	[TransactionNumber] [varchar](50) NULL,
	[TransactionType] [nvarchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[isExpo] [nvarchar](1) NULL,
	[isPriceBeat] [nvarchar](1) NULL,
	[isAgentSpecial] [nvarchar](1) NULL,
	[BonusDays] [int] NULL,
	[isClientCall] [nvarchar](1) NULL,
	[AllocationNumber] [int] NULL,
	[RiskNet] [float] NULL,
	[Premium] [float] NULL,
	[BookPremium] [float] NULL,
	[SellPrice] [float] NULL,
	[NetPrice] [float] NULL,
	[PremiumSD] [float] NULL,
	[PremiumGST] [float] NULL,
	[Commission] [float] NULL,
	[CommissionSD] [float] NULL,
	[CommissionGST] [float] NULL,
	[PremiumDiscount] [float] NULL,
	[AdminFee] [float] NULL,
	[AgentPremium] [float] NULL,
	[UnadjustedSellPrice] [float] NULL,
	[UnadjustedNetPrice] [float] NULL,
	[UnadjustedCommission] [float] NULL,
	[UnadjustedAdminFee] [float] NULL,
	[PolicyCount] [int] NULL,
	[AddonPolicyCount] [int] NULL,
	[ExtensionPolicyCount] [int] NULL,
	[CancelledPolicyCount] [int] NULL,
	[CancelledAddonPolicyCount] [int] NULL,
	[CANXPolicyCount] [int] NULL,
	[DomesticPolicyCount] [int] NULL,
	[InternationalPolicyCount] [int] NULL,
	[InboundPolicyCount] [int] NULL,
	[TravellersCount] [int] NULL,
	[AdultsCount] [int] NULL,
	[ChildrenCount] [int] NULL,
	[ChargedAdultsCount] [int] NULL,
	[DomesticTravellersCount] [int] NULL,
	[DomesticAdultsCount] [int] NULL,
	[DomesticChildrenCount] [int] NULL,
	[DomesticChargedAdultsCount] [int] NULL,
	[InboundTravellersCount] [int] NULL,
	[InboundAdultsCount] [int] NULL,
	[InboundChildrenCount] [int] NULL,
	[InboundChargedAdultsCount] [int] NULL,
	[InternationalTravellersCount] [int] NULL,
	[InternationalAdultsCount] [int] NULL,
	[InternationalChildrenCount] [int] NULL,
	[InternationalChargedAdultsCount] [int] NULL,
	[LuggageCount] [int] NULL,
	[MedicalCount] [int] NULL,
	[MotorcycleCount] [int] NULL,
	[RentalCarCount] [int] NULL,
	[WintersportCount] [int] NULL,
	[AttachmentCount] [int] NULL,
	[EMCCount] [int] NULL,
	[LoadDate] [datetime] NOT NULL,
	[LoadID] [int] NOT NULL,
	[updateDate] [datetime] NULL,
	[updateID] [int] NULL,
	[LeadTime] [int] NULL,
	[Duration] [int] NULL,
	[CancellationCover] [money] NULL,
	[PolicyIssueDate] [date] NULL,
	[DepartureDate] [date] NULL,
	[ReturnDate] [date] NULL,
	[UnderwriterCode] [varchar](100) NULL,
	[TransactionTypeStatusSK] [bigint] NULL,
	[DepartureDateSK] [date] NULL,
	[ReturnDateSK] [date] NULL,
	[IssueDateSK] [date] NULL,
	[CancelledTransactionCount] [int] NULL
) ON [PRIMARY]
GO
