USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_BusinessUnit_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_BusinessUnit_AU](
	[BusinessUnitId] [int] NOT NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[Domain] [nvarchar](255) NULL
) ON [PRIMARY]
GO
