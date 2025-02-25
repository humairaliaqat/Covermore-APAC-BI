USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimEstimateBalance]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimEstimateBalance](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[Date] [date] NOT NULL,
	[BenefitCategory] [varchar](35) NOT NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateBalance] [money] NULL,
	[RecoveryEstimateBalance] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimEstimateBalance_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmClaimEstimateBalance_BIRowID] ON [dbo].[clmClaimEstimateBalance]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimEstimateBalance_Date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimEstimateBalance_Date] ON [dbo].[clmClaimEstimateBalance]
(
	[Date] ASC,
	[CountryKey] ASC
)
INCLUDE([BenefitCategory],[SectionCode],[EstimateBalance],[RecoveryEstimateBalance]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
