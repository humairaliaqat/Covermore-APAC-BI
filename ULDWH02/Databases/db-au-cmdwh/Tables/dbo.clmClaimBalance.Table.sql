USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimBalance]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimBalance](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](41) NOT NULL,
	[OpeningDate] [date] NOT NULL,
	[EstimateOpening] [money] NULL,
	[ActiveOpening] [smallint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimBalance_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmClaimBalance_BIRowID] ON [dbo].[clmClaimBalance]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimBalance_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimBalance_ClaimKey] ON [dbo].[clmClaimBalance]
(
	[ClaimKey] ASC,
	[OpeningDate] DESC
)
INCLUDE([EstimateOpening],[ActiveOpening]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimBalance_Date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimBalance_Date] ON [dbo].[clmClaimBalance]
(
	[OpeningDate] ASC,
	[ClaimKey] ASC
)
INCLUDE([EstimateOpening],[ActiveOpening]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
