USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_campaigns_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_campaigns_AU](
	[id] [smallint] NOT NULL,
	[campaign] [nvarchar](4000) NOT NULL,
	[business_unit_id] [int] NOT NULL,
	[path_type] [nchar](1) NULL
) ON [PRIMARY]
GO
