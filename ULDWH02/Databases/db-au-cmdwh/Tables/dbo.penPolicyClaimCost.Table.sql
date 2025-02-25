USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyClaimCost]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyClaimCost](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date_SK] [int] NOT NULL,
	[Incurred Date] [datetime] NULL,
	[ClaimKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[Claim Number] [int] NULL,
	[Policy Number] [varchar](50) NULL,
	[Ultimate Cat] [money] NULL,
	[Ultimate Large] [money] NULL,
	[Ultimate Underlying] [money] NULL,
	[Incurred Cat] [money] NULL,
	[Incurred Large] [money] NULL,
	[Incurred Underlying] [money] NULL,
	[Projected Cat] [money] NULL,
	[Projected Large] [money] NULL,
	[Projected Underlying] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyClaimCost_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyClaimCost_BIRowID] ON [dbo].[penPolicyClaimCost]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyClaimCost_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyClaimCost_ClaimKey] ON [dbo].[penPolicyClaimCost]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyClaimCost_Date_SK]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyClaimCost_Date_SK] ON [dbo].[penPolicyClaimCost]
(
	[Date_SK] ASC
)
INCLUDE([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyClaimCost_IncurredDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyClaimCost_IncurredDate] ON [dbo].[penPolicyClaimCost]
(
	[Incurred Date] ASC
)
INCLUDE([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyClaimCost_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyClaimCost_PolicyTransactionKey] ON [dbo].[penPolicyClaimCost]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
