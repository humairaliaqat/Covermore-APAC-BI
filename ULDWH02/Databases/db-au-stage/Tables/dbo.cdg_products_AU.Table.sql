USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_products_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_products_AU](
	[id] [smallint] NOT NULL,
	[code] [nvarchar](4000) NULL,
	[plan_code] [nvarchar](4000) NULL,
	[product] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
