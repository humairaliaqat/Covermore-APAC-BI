USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penOutletEndorser]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penOutletEndorser](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[OutletKey] [varchar](71) NULL,
	[OutletID] [int] NOT NULL,
	[EndorserID] [int] NULL,
	[Endorser] [nvarchar](50) NULL,
	[EndorserList] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
