USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_penPolicyTransSummary]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_penPolicyTransSummary](
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[BasePolicyCount] [int] NOT NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[AutoComments] [nvarchar](2000) NULL,
	[UserComments] [nvarchar](1000) NULL,
	[CancellationReason] [nvarchar](250) NULL,
	[TopUp] [bit] NULL,
	[RefundToCustomer] [bit] NULL,
	[CNStatus] [varchar](200) NULL,
	[PromoCode] [nvarchar](40) NULL,
	[PromoName] [nvarchar](250) NULL,
	[PromoType] [nvarchar](50) NULL,
	[PromoDiscount] [numeric](10, 4) NULL,
	[CRMUserID] [int] NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[BasePolicyCountFix] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransSummary_PolicyTransactionKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransSummary_PolicyTransactionKey] ON [cng].[Tmp_penPolicyTransSummary]
(
	[PolicyTransactionKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransSummary_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransSummary_PolicyKeyProductCode] ON [cng].[Tmp_penPolicyTransSummary]
(
	[PolicyKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
