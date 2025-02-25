USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glJointVentures_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glJointVentures_ind](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[JVCode] [varchar](50) NOT NULL,
	[JVDescription] [nvarchar](255) NULL,
	[TypeOfJVCode] [varchar](50) NULL,
	[TypeOfJVDescription] [nvarchar](200) NULL,
	[DistributionTypeCode] [varchar](50) NULL,
	[DistributionTypeDescription] [nvarchar](200) NULL,
	[SuperGroupCode] [varchar](50) NULL,
	[SuperGroupDescription] [nvarchar](200) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[glJointVentures_ind]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ind] ON [dbo].[glJointVentures_ind]
(
	[JVCode] ASC
)
INCLUDE([JVDescription],[TypeOfJVCode],[TypeOfJVDescription],[DistributionTypeCode],[DistributionTypeDescription],[SuperGroupCode],[SuperGroupDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
