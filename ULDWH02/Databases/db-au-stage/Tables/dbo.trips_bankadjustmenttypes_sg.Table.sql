USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bankadjustmenttypes_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bankadjustmenttypes_sg](
	[AdjTypeID] [smallint] NOT NULL,
	[AdjDesc] [varchar](15) NULL
) ON [PRIMARY]
GO
