USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyPortfolio]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyPortfolio](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Posting Date] [datetime] NULL,
	[Date_SK] [int] NOT NULL,
	[Fiscal Period] [int] NULL,
	[Alpha] [nvarchar](20) NOT NULL,
	[Business Unit] [varchar](3) NULL,
	[JV] [varchar](50) NOT NULL,
	[Product Code] [nvarchar](50) NULL,
	[Product Type] [varchar](50) NULL,
	[Policy Number] [varchar](50) NULL,
	[Policy Count] [int] NOT NULL,
	[Premium] [money] NULL,
	[Distributor Recovery] [money] NULL,
	[Agency Commission] [money] NULL,
	[Override] [money] NULL,
	[Merchant Fee] [money] NOT NULL,
	[Arrangement Fee] [money] NOT NULL,
	[Pay Per Click] [money] NOT NULL,
	[Assistance Fees] [money] NOT NULL,
	[Underwriter Net] [money] NOT NULL,
	[Claims Expense] [money] NOT NULL,
	[Underwriter Margin] [money] NOT NULL,
	[Direct Employment Expenses] [money] NOT NULL,
	[Direct Other Expenses] [money] NOT NULL,
	[Advertising, Research & Promotion] [money] NOT NULL,
	[Printing & Postage] [money] NOT NULL,
	[Overhead Employment Expenses] [money] NOT NULL,
	[Overhead Other Expenses] [money] NOT NULL,
	[GL Agent Commission] [money] NOT NULL,
	[GL Distributor Recovery] [money] NOT NULL,
	[GL Premium Income] [money] NOT NULL,
	[GL Agency Overrides] [money] NOT NULL,
	[Commission Received - Care] [money] NOT NULL,
	[Affiliate Commission] [money] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyPortfolio_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyPortfolio_BIRowID] ON [dbo].[penPolicyPortfolio]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyPortfolio_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyPortfolio_PolicyTransactionKey] ON [dbo].[penPolicyPortfolio]
(
	[PolicyTransactionKey] ASC,
	[Date_SK] ASC
)
INCLUDE([Underwriter Margin]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyPortfolio_PostingDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyPortfolio_PostingDate] ON [dbo].[penPolicyPortfolio]
(
	[Posting Date] ASC
)
INCLUDE([PolicyTransactionKey],[Business Unit],[Policy Count],[Premium],[Distributor Recovery],[Agency Commission],[Override],[Merchant Fee],[Arrangement Fee],[Pay Per Click],[Assistance Fees],[Underwriter Net],[Claims Expense],[Underwriter Margin],[Direct Employment Expenses],[Direct Other Expenses],[Advertising, Research & Promotion],[Printing & Postage],[Overhead Employment Expenses],[Overhead Other Expenses],[GL Agent Commission],[GL Distributor Recovery],[GL Premium Income],[GL Agency Overrides],[Commission Received - Care],[Affiliate Commission]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
