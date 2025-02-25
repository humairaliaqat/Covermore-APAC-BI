USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Penpolicytransaction_20200514_INC0164196_130]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Penpolicytransaction_20200514_INC0164196_130](
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
	[GrossPremium] [money] NOT NULL,
	[IssueDate] [datetime] NOT NULL,
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
	[TripCost] [varchar](50) NULL,
	[AllocationNumber] [int] NULL,
	[PaymentDate] [datetime] NULL,
	[TransactionStart] [datetime] NULL,
	[TransactionEnd] [datetime] NULL,
	[StoreCode] [varchar](10) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[IssueDateUTC] [datetime] NULL,
	[PaymentDateUTC] [datetime] NULL,
	[TransactionStartUTC] [datetime] NULL,
	[TransactionEndUTC] [datetime] NULL,
	[ImportDate] [datetime] NULL,
	[TransactionDateTime] [datetime] NULL,
	[TotalCommission] [money] NULL,
	[TotalNet] [money] NULL,
	[PaymentMode] [nvarchar](20) NULL,
	[PointsRedeemed] [money] NULL,
	[RedemptionReference] [nvarchar](255) NULL,
	[GigyaId] [nvarchar](300) NULL,
	[IssuingConsultantID] [int] NULL,
	[LeadTimeDate] [date] NULL,
	[MaxAMTDuration] [int] NULL,
	[RefundTransactionID] [int] NULL,
	[RefundTransactionKey] [varchar](41) NULL
) ON [PRIMARY]
GO
