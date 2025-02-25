USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entPolicy]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entPolicy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[SourceSystem] [nchar](14) NULL,
	[Reference] [nvarchar](300) NULL,
	[ClaimKey] [varchar](40) NULL,
	[PolicyKey] [varchar](41) NULL,
	[UpdateBatchID] [bigint] NULL,
	[FTS] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_entPolicy_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_entPolicy_BIRowID] ON [dbo].[entPolicy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entPolicy_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPolicy_ClaimKey] ON [dbo].[entPolicy]
(
	[ClaimKey] ASC
)
INCLUDE([BIRowID],[CustomerID],[PolicyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_entPolicy_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPolicy_CustomerID] ON [dbo].[entPolicy]
(
	[CustomerID] ASC
)
INCLUDE([BIRowID],[PolicyKey],[ClaimKey],[Reference]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entPolicy_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPolicy_PolicyKey] ON [dbo].[entPolicy]
(
	[PolicyKey] ASC,
	[Reference] ASC
)
INCLUDE([BIRowID],[CustomerID],[ClaimKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entPolicy_Reference]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPolicy_Reference] ON [dbo].[entPolicy]
(
	[Reference] ASC,
	[SourceSystem] ASC
)
INCLUDE([PolicyKey],[ClaimKey],[BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
