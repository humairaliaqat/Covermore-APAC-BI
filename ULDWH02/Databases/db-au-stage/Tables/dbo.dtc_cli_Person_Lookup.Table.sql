USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Person_Lookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Person_Lookup](
	[uniqueindid] [nvarchar](4000) NOT NULL,
	[kindid] [int] NOT NULL,
	[kbookitemid] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Person_Lookup_uniqueindid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Person_Lookup_uniqueindid] ON [dbo].[dtc_cli_Person_Lookup]
(
	[uniqueindid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
