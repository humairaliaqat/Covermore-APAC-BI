USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btsitefee_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btsitefee_audtc](
	[kitemid] [int] NOT NULL,
	[ksiteid] [int] NOT NULL,
	[sitefee] [numeric](10, 2) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
