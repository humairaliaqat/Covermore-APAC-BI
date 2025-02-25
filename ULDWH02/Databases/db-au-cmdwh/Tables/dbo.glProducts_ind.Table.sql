USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glProducts_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glProducts_ind](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentProductCode] [varchar](50) NOT NULL,
	[ParentProductDescription] [nvarchar](255) NULL,
	[ProductCode] [varchar](50) NOT NULL,
	[ProductDescription] [nvarchar](255) NULL,
	[ProductTypeCode] [varchar](50) NOT NULL,
	[ProductTypeDescription] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[glProducts_ind]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ind] ON [dbo].[glProducts_ind]
(
	[ProductCode] ASC
)
INCLUDE([ParentProductCode],[ParentProductDescription],[ProductDescription],[ProductTypeCode],[ProductTypeDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent_ind] ON [dbo].[glProducts_ind]
(
	[ParentProductCode] ASC
)
INCLUDE([ProductCode],[ProductDescription],[ParentProductDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
