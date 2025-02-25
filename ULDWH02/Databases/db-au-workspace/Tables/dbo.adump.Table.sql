USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[adump]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adump](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[PaymentID] [int] NOT NULL,
	[PaymentAmount] [money] NULL,
	[EncryptBSB] [varbinary](256) NULL,
	[EncryptAccount] [varbinary](256) NULL,
	[Account] [varchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_account]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_account] ON [dbo].[adump]
(
	[Account] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
