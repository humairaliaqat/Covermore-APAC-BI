USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgdimMultiDestination]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgdimMultiDestination](
	[dimCovermoreCountryListID] [int] NOT NULL,
	[MultiDestination] [varchar](8000) NULL
) ON [PRIMARY]
GO
