USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCFinancial]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCFinancial](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[FunderSK] [int] NULL,
	[AllocatedName] [nvarchar](100) NULL,
	[ServiceSK] [int] NULL,
	[ServiceEventActivitySK] [int] NULL,
	[Revenue] [money] NULL,
	[Cost] [money] NULL,
	[GLCompanyID] [int] NULL,
	[GLJournalID] [nvarchar](50) NULL,
	[GLSequenceID] [int] NULL,
	[GLJournalDesc] [varchar](100) NULL,
	[UserSK] [int] NULL,
	[Type] [nvarchar](30) NULL,
	[ServiceEventActivityID] [varchar](50) NULL,
	[GLAccountCode] [varchar](20) NULL,
	[NatAmount] [money] NULL,
	[CurrencyCode] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_usrDTCFinancial_Cost]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [IDX_usrDTCFinancial_Cost] ON [dbo].[usr_DTCFinancial]
(
	[Cost] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_usrDTCFinancial_Date]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [IDX_usrDTCFinancial_Date] ON [dbo].[usr_DTCFinancial]
(
	[Date] ASC
)
INCLUDE([FunderSK],[AllocatedName],[ServiceSK],[Revenue],[GLJournalID],[GLSequenceID],[GLJournalDesc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
