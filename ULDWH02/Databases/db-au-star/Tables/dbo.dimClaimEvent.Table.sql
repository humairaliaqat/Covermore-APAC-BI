USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimClaimEvent]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimClaimEvent](
	[ClaimEventSK] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[EventKey] [varchar](40) NOT NULL,
	[EventType] [varchar](15) NOT NULL,
	[EventCountryCode] [varchar](10) NOT NULL,
	[EventCountryName] [nvarchar](45) NOT NULL,
	[CatastropheCode] [varchar](10) NOT NULL,
	[Catastrophe] [nvarchar](20) NOT NULL,
	[PerilCode] [varchar](10) NOT NULL,
	[Peril] [nvarchar](65) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimClaimEvent_ClaimEventSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_dimClaimEvent_ClaimEventSK] ON [dbo].[dimClaimEvent]
(
	[ClaimEventSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimClaimEvent_ClaimKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimClaimEvent_ClaimKey] ON [dbo].[dimClaimEvent]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimClaimEvent_EventKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimClaimEvent_EventKey] ON [dbo].[dimClaimEvent]
(
	[EventKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
