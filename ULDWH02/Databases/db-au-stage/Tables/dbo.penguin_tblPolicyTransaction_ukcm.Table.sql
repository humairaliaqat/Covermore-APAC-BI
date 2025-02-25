USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTransaction_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTransaction_ukcm](
	[ID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[TripsPolicyNumber] [varchar](25) NULL,
	[TransactionType] [int] NOT NULL,
	[GrossPremium] [money] NOT NULL,
	[IssueDate] [datetime] NOT NULL,
	[AccountingPeriod] [datetime] NOT NULL,
	[CRMUserID] [int] NULL,
	[TransactionStatus] [int] NOT NULL,
	[Transferred] [bit] NOT NULL,
	[UserComments] [nvarchar](1000) NULL,
	[CommissionTier] [varchar](50) NULL,
	[VolumeCommission] [numeric](18, 9) NULL,
	[Discount] [numeric](18, 9) NULL,
	[IsExpo] [bit] NOT NULL,
	[IsPriceBeat] [bit] NOT NULL,
	[NoOfBonusDaysApplied] [int] NULL,
	[IsAgentSpecial] [bit] NOT NULL,
	[ParentID] [int] NULL,
	[ConsultantID] [int] NULL,
	[IsClientCall] [bit] NULL,
	[RiskNet] [money] NULL,
	[AutoComments] [nvarchar](2000) NULL,
	[TripCost] [nvarchar](50) NULL,
	[AllocationNumber] [int] NULL,
	[PaymentDate] [datetime] NULL,
	[TransactionStart] [datetime] NULL,
	[TransactionEnd] [datetime] NULL,
	[StoreCode] [varchar](10) NULL,
	[TotalCommission] [money] NULL,
	[TotalNet] [money] NULL,
	[TransactionDateTime] [datetime] NULL,
	[PaymentMode] [nvarchar](20) NULL,
	[PointsRedeemed] [money] NULL,
	[IssuingConsultantId] [int] NOT NULL,
	[GigyaId] [nvarchar](300) NULL,
	[LeadTimeDate] [date] NOT NULL,
	[RefundTransactionId] [int] NULL,
	[TopUp] [bit] NULL,
	[RefundToCustomer] [bit] NULL,
	[CNStatusID] [int] NULL,
	[RequestedTravellerID] [int] NULL,
	[CancellationReason] [nvarchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTransaction_ukcm_ID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyTransaction_ukcm_ID] ON [dbo].[penguin_tblPolicyTransaction_ukcm]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTransaction_ukcm_DomainID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicyTransaction_ukcm_DomainID] ON [dbo].[penguin_tblPolicyTransaction_ukcm]
(
	[ID] ASC
)
INCLUDE([PolicyID],[CRMUserID],[ConsultantID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTransaction_ukcm_PolicyID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicyTransaction_ukcm_PolicyID] ON [dbo].[penguin_tblPolicyTransaction_ukcm]
(
	[PolicyID] ASC
)
INCLUDE([TripCost]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
