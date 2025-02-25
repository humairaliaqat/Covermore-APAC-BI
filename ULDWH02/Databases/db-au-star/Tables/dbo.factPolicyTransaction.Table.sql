USE [db-au-star]
GO
/****** Object:  Table [dbo].[factPolicyTransaction]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTransaction](
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
/****** Object:  Index [idx_factPolicyTransaction_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransaction_DateSK] ON [dbo].[factPolicyTransaction]
(
	[DateSK] ASC,
	[OutletSK] ASC
)
INCLUDE([DomainSK],[Premium],[Commission],[PolicyCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factPolicyTransaction_PolicySK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransaction_PolicySK] ON [dbo].[factPolicyTransaction]
(
	[PolicySK] ASC,
	[TransactionType] ASC,
	[TransactionStatus] ASC
)
INCLUDE([DateSK],[DomainSK],[OutletSK],[ConsultantSK],[AreaSK],[DestinationSK],[DurationSK],[ProductSK],[AgeBandSK],[EMCCount],[Premium]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factPolicyTransaction_PolicyTransactionKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransaction_PolicyTransactionKey] ON [dbo].[factPolicyTransaction]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([DateSK],[DomainSK],[OutletSK],[PolicySK],[ConsultantSK],[PaymentSK],[AreaSK],[DestinationSK],[DurationSK],[ProductSK],[AgeBandSK],[PromotionSK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factPolicyTransaction_PostingDate]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factPolicyTransaction_PostingDate] ON [dbo].[factPolicyTransaction]
(
	[PostingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ccsi_factPolicyTransaction]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED COLUMNSTORE INDEX [ccsi_factPolicyTransaction] ON [dbo].[factPolicyTransaction] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
