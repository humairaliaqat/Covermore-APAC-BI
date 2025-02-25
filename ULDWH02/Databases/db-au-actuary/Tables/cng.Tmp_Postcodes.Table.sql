USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_Postcodes]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_Postcodes](
	[id] [float] NULL,
	[postcode] [nvarchar](255) NULL,
	[locality] [nvarchar](255) NULL,
	[state] [nvarchar](255) NULL,
	[long] [float] NULL,
	[lat] [float] NULL,
	[dc] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL,
	[status] [nvarchar](255) NULL,
	[sa3] [float] NULL,
	[sa3name] [nvarchar](255) NULL,
	[sa4] [float] NULL,
	[sa4name] [nvarchar](255) NULL,
	[region] [nvarchar](255) NULL
) ON [PRIMARY]
GO
