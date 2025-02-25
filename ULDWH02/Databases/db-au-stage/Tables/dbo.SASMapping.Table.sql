USE [db-au-stage]
GO
/****** Object:  Table [dbo].[SASMapping]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SASMapping](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[FieldName] [varchar](64) NULL,
	[OriginalValue] [nvarchar](255) NULL,
	[MappedValue] [nvarchar](255) NULL
) ON [PRIMARY]
GO
