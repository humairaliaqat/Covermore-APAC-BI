USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usrRPT0187]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0187](
	[ChequeID] [int] NULL,
	[ChequeNo] [bigint] NULL,
	[ClaimNo] [int] NULL,
	[Status] [varchar](10) NULL,
	[TransactionType] [varchar](4) NULL,
	[Currency] [varchar](4) NULL,
	[Amount] [money] NULL,
	[PaymentDate] [datetime] NULL,
	[NameID] [int] NULL,
	[Title] [nvarchar](50) NULL,
	[Firstname] [nvarchar](100) NULL,
	[Surname] [nvarchar](100) NULL,
	[AccountName] [varchar](100) NULL,
	[AccountNo] [varchar](500) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_account]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_account] ON [dbo].[usrRPT0187]
(
	[AccountNo] ASC
)
INCLUDE([ClaimNo],[PaymentDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
