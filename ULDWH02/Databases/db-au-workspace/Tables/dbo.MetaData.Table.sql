USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MetaData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaData](
	[ccrFK] [bigint] NOT NULL,
	[metaDataFieldFK] [int] NOT NULL,
	[data] [nvarchar](2056) NOT NULL,
	[hashedData] [varbinary](20) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[MetaData]
(
	[ccrFK] ASC
)
INCLUDE([metaDataFieldFK],[data]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
