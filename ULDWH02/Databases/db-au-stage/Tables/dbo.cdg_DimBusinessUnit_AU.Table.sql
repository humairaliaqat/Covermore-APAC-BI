USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimBusinessUnit_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimBusinessUnit_AU](
	[DimBusinessUnitID] [int] NOT NULL,
	[BusinessUnitName] [varchar](100) NOT NULL,
	[Domain] [char](2) NOT NULL,
	[Partner] [varchar](50) NULL,
	[Currency] [char](3) NULL
) ON [PRIMARY]
GO
