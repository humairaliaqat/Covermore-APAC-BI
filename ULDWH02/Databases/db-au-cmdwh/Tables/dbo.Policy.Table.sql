USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Policy]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy](
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[AgencySKey] [bigint] NULL,
	[AgencyKey] [varchar](10) NULL,
	[CustomerKey] [varchar](41) NULL,
	[ConsultantKey] [varchar](13) NULL,
	[CountryPolicyKey] [varchar](13) NULL,
	[BatchNo] [varchar](8) NULL,
	[PolicyNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
	[PolicyType] [varchar](5) NULL,
	[ProductCode] [varchar](5) NULL,
	[OldPolicyNo] [int] NULL,
	[OldPolicyType] [varchar](5) NULL,
	[OldProductCode] [varchar](5) NULL,
	[OldPlanCode] [varchar](6) NULL,
	[NumberOfChildren] [smallint] NULL,
	[NumberOfAdults] [smallint] NULL,
	[NumberOfPersons] [smallint] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[NumberOfDays] [smallint] NULL,
	[NumberOfBonusDays] [tinyint] NULL,
	[NumberOfWeeks] [tinyint] NULL,
	[NumberOfMonths] [tinyint] NULL,
	[Destination] [varchar](50) NULL,
	[TripCost] [varchar](100) NULL,
	[AgencyCode] [varchar](7) NULL,
	[ConsultantInitial] [varchar](2) NULL,
	[ConsultantName] [varchar](50) NULL,
	[PlanCode] [varchar](6) NULL,
	[Excess] [smallint] NULL,
	[SingleFamily] [varchar](1) NULL,
	[PolicyComment] [varchar](250) NULL,
	[BasePremium] [money] NULL,
	[MedicalPremium] [money] NULL,
	[LuggagePremium] [money] NULL,
	[MotorcyclePremium] [money] NULL,
	[RentalCarPremium] [money] NULL,
	[WinterSportPremium] [money] NULL,
	[GrossPremiumExGSTBeforeDiscount] [money] NULL,
	[NetPremium] [money] NULL,
	[NetRate] [float] NULL,
	[CommissionRate] [float] NULL,
	[CommissionAmount] [money] NULL,
	[CommissionTierID] [varchar](25) NULL,
	[GSTonGrossPremium] [money] NULL,
	[GSTOnCommission] [money] NULL,
	[StampDuty] [money] NULL,
	[ActualCommissionAfterDiscount] [money] NULL,
	[ActualGrossPremiumAfterDiscount] [money] NULL,
	[ActualLuggagePremiumAfterDiscount] [money] NULL,
	[ActualMedicalPremiumAfterDiscount] [money] NULL,
	[ActualRentalCarPremiumAfterDiscount] [money] NULL,
	[RentalCarPremiumCovered] [float] NULL,
	[ActualAdminFee] [money] NULL,
	[ActualAdminFeeAfterDiscount] [money] NULL,
	[RiskNet] [float] NULL,
	[VolumePercentage] [float] NULL,
	[NetAdjustmentFactor] [float] NULL,
	[CancellationPremium] [money] NULL,
	[ActualCancellationPremiumAfterDiscount] [money] NULL,
	[CancellationCoverValue] [varchar](100) NULL,
	[PaymentDate] [datetime] NULL,
	[BankPaymentRecord] [int] NULL,
	[AgentReference] [varchar](50) NULL,
	[ModeOfTransport] [varchar](10) NULL,
	[StoreCode] [varchar](10) NULL,
	[AccountingDate] [datetime] NULL,
	[YAGOIssuedDate] [datetime] NULL,
	[CompanyKey] [varchar](5) NULL,
	[AreaType] [varchar](50) NULL,
	[AreaNo] [varchar](20) NULL,
	[isTripsPolicy] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_IssuedDate]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_Policy_IssuedDate] ON [dbo].[Policy]
(
	[IssuedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_AgencyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_AgencyKey] ON [dbo].[Policy]
(
	[AgencyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_AgencySKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_AgencySKey] ON [dbo].[Policy]
(
	[AgencySKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_BankPaymentRecord]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_BankPaymentRecord] ON [dbo].[Policy]
(
	[BankPaymentRecord] ASC,
	[CountryKey] ASC,
	[AgencyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_ConsultantKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_ConsultantKey] ON [dbo].[Policy]
(
	[ConsultantKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_CountryKey] ON [dbo].[Policy]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_CountryPolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_CountryPolicyKey] ON [dbo].[Policy]
(
	[CountryPolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_CreateDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_CreateDate] ON [dbo].[Policy]
(
	[CreateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_CustomerKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_CustomerKey] ON [dbo].[Policy]
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_DepartureDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_DepartureDate] ON [dbo].[Policy]
(
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_OldPolicyNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_OldPolicyNo] ON [dbo].[Policy]
(
	[OldPolicyNo] ASC,
	[CountryKey] ASC,
	[PolicyType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_PaymentDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_PaymentDate] ON [dbo].[Policy]
(
	[PaymentDate] ASC,
	[AgencyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_PolicyKey] ON [dbo].[Policy]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_PolicyNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_PolicyNo] ON [dbo].[Policy]
(
	[PolicyNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_PolicyType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_PolicyType] ON [dbo].[Policy]
(
	[PolicyType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_ProductCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_ProductCode] ON [dbo].[Policy]
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_ReturnDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_ReturnDate] ON [dbo].[Policy]
(
	[ReturnDate] ASC,
	[CountryKey] ASC,
	[PolicyType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Policy_YAGOIssuedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_YAGOIssuedDate] ON [dbo].[Policy]
(
	[YAGOIssuedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
