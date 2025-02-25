USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimTAPlanType]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimTAPlanType](
	[TAPlanTypeSK] [int] IDENTITY(1,1) NOT NULL,
	[TAPlanTypeID] [int] NOT NULL,
	[PlanType] [nvarchar](50) NULL,
	[CardImage] [nvarchar](500) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimTAPlanType_TAPlanTypeSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimTAPlanType_TAPlanTypeSK] ON [dbo].[trwdimTAPlanType]
(
	[TAPlanTypeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimTAPlanType_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimTAPlanType_HashKey] ON [dbo].[trwdimTAPlanType]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimTAPlanType_TAPlanTypeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimTAPlanType_TAPlanTypeID] ON [dbo].[trwdimTAPlanType]
(
	[TAPlanTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
