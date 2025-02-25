USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFLEmployee]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFLEmployee](
	[T4] [varchar](20) NULL,
	[T3] [varchar](6) NULL,
	[BusinessName] [nvarchar](255) NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[PsuedoCode] [nvarchar](255) NULL,
	[JobTitle] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[FTEName] [nvarchar](255) NULL,
	[FTEValue] [float] NULL,
	[BusTypeName] [nvarchar](255) NULL,
	[CountryName] [nvarchar](255) NULL,
	[DivisionName] [nvarchar](255) NULL,
	[Brand] [nvarchar](255) NULL,
	[Nation] [nvarchar](255) NULL,
	[BusAddress1] [nvarchar](255) NULL,
	[BusAddress2] [nvarchar](255) NULL,
	[BusAddress3] [nvarchar](255) NULL,
	[BusLocality] [nvarchar](255) NULL,
	[BusState] [nvarchar](255) NULL,
	[BusPostcode] [float] NULL
) ON [PRIMARY]
GO
