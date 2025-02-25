USE [db-au-bobj]
GO
/****** Object:  Table [dbo].[CMS_Aliases7]    Script Date: 21/02/2025 11:29:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS_Aliases7](
	[ObjectID] [int] NOT NULL,
	[AliasIsTruncated] [int] NOT NULL,
	[Alias] [nvarchar](255) NULL,
	[EmailAddress] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [CMS_Aliases7_I0]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE NONCLUSTERED INDEX [CMS_Aliases7_I0] ON [dbo].[CMS_Aliases7]
(
	[ObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [CMS_Aliases7_I1]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE NONCLUSTERED INDEX [CMS_Aliases7_I1] ON [dbo].[CMS_Aliases7]
(
	[AliasIsTruncated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CMS_Aliases7_I2]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE NONCLUSTERED INDEX [CMS_Aliases7_I2] ON [dbo].[CMS_Aliases7]
(
	[Alias] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CMS_Aliases7_I3]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE NONCLUSTERED INDEX [CMS_Aliases7_I3] ON [dbo].[CMS_Aliases7]
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
