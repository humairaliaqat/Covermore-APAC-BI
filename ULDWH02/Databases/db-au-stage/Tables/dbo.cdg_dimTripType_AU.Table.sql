USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimTripType_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimTripType_AU](
	[DimTripTypeID] [int] NOT NULL,
	[TripTypeName] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
