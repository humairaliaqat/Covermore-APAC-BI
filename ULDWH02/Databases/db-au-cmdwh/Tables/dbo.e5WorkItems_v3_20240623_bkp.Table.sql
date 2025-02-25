USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkItems_v3_20240623_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkItems_v3_20240623_bkp](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[ItemKey] [varchar](50) NULL,
	[ID] [int] NOT NULL,
	[Code] [nvarchar](32) NULL,
	[Name] [nvarchar](400) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
