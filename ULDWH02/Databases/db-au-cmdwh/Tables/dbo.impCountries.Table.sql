USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impCountries]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impCountries](
	[id] [smallint] NOT NULL,
	[code] [nvarchar](50) NULL,
	[country] [nvarchar](100) NULL
) ON [PRIMARY]
GO
