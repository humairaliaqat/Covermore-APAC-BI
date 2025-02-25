USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_e5Work]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_e5Work](
	[Id] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_etle5Work_ID]    Script Date: 24/02/2025 5:08:04 PM ******/
CREATE CLUSTERED INDEX [idx_etle5Work_ID] ON [dbo].[etl_e5Work]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
