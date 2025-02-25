USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimEstimateMovement]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimEstimateMovement](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[BenefitCategory] [varchar](35) NOT NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateDate] [date] NULL,
	[EstimateDateUTC] [date] NULL,
	[EstimateCategory] [varchar](20) NULL,
	[EstimateMovement] [decimal](20, 6) NULL,
	[RecoveryEstimateMovement] [decimal](20, 6) NULL,
	[PaidOnPeriod] [decimal](20, 6) NULL,
	[BatchID] [int] NULL,
	[EstimateDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimEstimateMovement_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmClaimEstimateMovement_BIRowID] ON [dbo].[clmClaimEstimateMovement]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimEstimateMovement_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimEstimateMovement_ClaimKey] ON [dbo].[clmClaimEstimateMovement]
(
	[ClaimKey] ASC,
	[EstimateDate] ASC
)
INCLUDE([EstimateMovement],[BenefitCategory],[EstimateCategory],[RecoveryEstimateMovement],[EstimateDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimEstimateMovement_EstimateDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimEstimateMovement_EstimateDate] ON [dbo].[clmClaimEstimateMovement]
(
	[EstimateDate] ASC,
	[EstimateDateTime] ASC
)
INCLUDE([ClaimKey],[SectionKey],[EstimateMovement],[RecoveryEstimateMovement]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimEstimateMovement_EstimateDateUTC]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimEstimateMovement_EstimateDateUTC] ON [dbo].[clmClaimEstimateMovement]
(
	[EstimateDateUTC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimEstimateMovement_SectionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimEstimateMovement_SectionKey] ON [dbo].[clmClaimEstimateMovement]
(
	[SectionKey] ASC,
	[EstimateDate] ASC
)
INCLUDE([ClaimKey],[EstimateMovement],[BenefitCategory],[EstimateCategory],[RecoveryEstimateMovement],[EstimateDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
