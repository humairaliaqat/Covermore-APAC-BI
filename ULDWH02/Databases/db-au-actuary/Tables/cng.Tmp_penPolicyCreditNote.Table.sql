USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_penPolicyCreditNote]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_penPolicyCreditNote](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NOT NULL,
	[CreditNotePolicyKey] [varchar](71) NOT NULL,
	[ID] [int] NOT NULL,
	[CreditNoteNumber] [nvarchar](15) NOT NULL,
	[OriginalPolicyId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[RedeemPolicyId] [int] NULL,
	[RedeemAmount] [money] NULL,
	[Status] [varchar](15) NOT NULL,
	[DomainId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[Commission] [money] NULL,
	[RedeemedCommission] [money] NULL,
	[CNStatusID] [int] NULL,
	[OriginalPolicyKey] [varchar](41) NULL,
	[OriginalProductCode] [nvarchar](50) NULL,
	[RedeemPolicyKey] [varchar](41) NULL,
	[RedeemProductCode] [nvarchar](50) NULL,
	[CreditNoteStartDate] [datetime] NULL,
	[CreditNoteExpiryDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyCreditNote_CreditNotePolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penPolicyCreditNote_CreditNotePolicyKey] ON [cng].[Tmp_penPolicyCreditNote]
(
	[CreditNotePolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyCreditNote_CreditNoteNumber]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyCreditNote_CreditNoteNumber] ON [cng].[Tmp_penPolicyCreditNote]
(
	[CreditNoteNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyCreditNote_OriginalPolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyCreditNote_OriginalPolicyKey] ON [cng].[Tmp_penPolicyCreditNote]
(
	[OriginalPolicyKey] ASC,
	[OriginalProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyCreditNote_RedeemPolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyCreditNote_RedeemPolicyKey] ON [cng].[Tmp_penPolicyCreditNote]
(
	[RedeemPolicyKey] ASC,
	[RedeemProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
