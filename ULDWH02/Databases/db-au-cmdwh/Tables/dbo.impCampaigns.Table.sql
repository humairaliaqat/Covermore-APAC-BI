USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impCampaigns]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impCampaigns](
	[id] [smallint] NOT NULL,
	[campaign] [nvarchar](50) NULL,
	[business_unit_id] [smallint] NULL,
	[path_type] [nchar](1) NULL,
 CONSTRAINT [pk_impCampaigns] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
