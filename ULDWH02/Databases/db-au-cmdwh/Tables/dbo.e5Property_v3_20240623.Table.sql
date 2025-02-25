USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5Property_v3_20240623]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5Property_v3_20240623](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[PropertyKey] [nvarchar](40) NULL,
	[ID] [nvarchar](32) NULL,
	[PropertyLabel] [nvarchar](100) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
