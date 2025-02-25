USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glAccounts]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glAccounts](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentAccountCode] [varchar](50) NULL,
	[AccountCode] [varchar](50) NOT NULL,
	[AccountDescription] [nvarchar](255) NULL,
	[AccountHierarchyType] [varchar](200) NULL,
	[AccountCategory] [nvarchar](50) NULL,
	[AccountOperator] [char](1) NULL,
	[AccountOrder] [int] NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL,
	[FIPAccount] [varchar](50) NULL,
	[SAPPE3Account] [varchar](50) NULL,
	[FIPTOB] [varchar](50) NULL,
	[SAPTOB] [varchar](50) NULL,
	[TOM] [varchar](50) NULL,
	[AccountType] [varchar](5) NULL,
	[StatutoryMapping] [nvarchar](255) NULL,
	[InternalMapping] [nvarchar](255) NULL,
	[Technical] [varchar](5) NULL,
	[Intercompany] [varchar](5) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[glAccounts]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[glAccounts]
(
	[AccountCode] ASC
)
INCLUDE([ParentAccountCode],[AccountDescription],[AccountHierarchyType],[AccountCategory],[AccountOperator],[AccountOrder]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
