USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_business_units_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_business_units_AU](
	[id] [int] NOT NULL,
	[business_unit] [nvarchar](4000) NULL,
	[domain] [nvarchar](4000) NULL,
	[partner] [nvarchar](4000) NULL,
	[currency] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
