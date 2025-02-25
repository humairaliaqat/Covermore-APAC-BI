USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lucountry_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lucountry_audtc](
	[lucountryid] [int] NOT NULL,
	[country] [nvarchar](30) NOT NULL,
	[countryshort] [nvarchar](3) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[country2charcode] [nchar](2) NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
