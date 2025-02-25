USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgDestination]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgDestination](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[DestinationCountryID] [int] NOT NULL,
	[DestinationCountryCode] [nvarchar](3) NULL,
	[DestinationCountry] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgDestination_main]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgDestination_main] ON [dbo].[cdgDestination]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgDestination_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgDestination_id] ON [dbo].[cdgDestination]
(
	[DestinationCountryID] ASC
)
INCLUDE([DestinationCountryCode],[DestinationCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
