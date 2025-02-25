USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entEmail]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entEmail](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmailID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[STATUS] [nvarchar](10) NULL,
	[SourceSystem] [nchar](14) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[EmailType] [nvarchar](20) NULL,
	[UpdateBatchID] [bigint] NULL,
	[UserAddress] [nvarchar](255) NULL,
	[Domain] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_entEmail_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_entEmail_BIRowID] ON [dbo].[entEmail]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_entEmail_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entEmail_CustomerID] ON [dbo].[entEmail]
(
	[CustomerID] ASC
)
INCLUDE([BIRowID],[EmailID],[EmailAddress]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entEmail_EmailAddress]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entEmail_EmailAddress] ON [dbo].[entEmail]
(
	[EmailAddress] ASC
)
INCLUDE([BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entEmail_UserAddress]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entEmail_UserAddress] ON [dbo].[entEmail]
(
	[UserAddress] ASC,
	[Domain] ASC
)
INCLUDE([BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
