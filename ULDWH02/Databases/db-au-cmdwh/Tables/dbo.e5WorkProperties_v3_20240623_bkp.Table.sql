USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkProperties_v3_20240623_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkProperties_v3_20240623_bkp](
	[Domain] [varchar](5) NULL,
	[Country] [varchar](5) NULL,
	[Work_ID] [varchar](50) NULL,
	[Original_Work_ID] [uniqueidentifier] NOT NULL,
	[Property_ID] [nvarchar](32) NULL,
	[PropertyValue] [sql_variant] NULL,
	[UpdateBatchID] [int] NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
