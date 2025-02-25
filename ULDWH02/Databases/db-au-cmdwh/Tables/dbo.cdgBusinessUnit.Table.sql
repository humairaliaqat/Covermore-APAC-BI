USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgBusinessUnit]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgBusinessUnit](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[Domain] [nvarchar](255) NULL,
	[Partner] [nvarchar](255) NULL,
	[Currency] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgBusinessUnit_main]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgBusinessUnit_main] ON [dbo].[cdgBusinessUnit]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgBusinessUnit_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgBusinessUnit_id] ON [dbo].[cdgBusinessUnit]
(
	[BusinessUnitID] ASC
)
INCLUDE([BusinessUnit],[Domain]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
