USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[au_phone]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[au_phone](
	[Phone] [varchar](50) NULL,
	[RecCount] [int] NULL,
	[valid] [bit] NULL,
	[formatted] [varchar](max) NULL,
	[countrycode] [varchar](max) NULL,
	[areacode] [varchar](max) NULL,
	[numberonly] [varchar](max) NULL,
	[line] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
