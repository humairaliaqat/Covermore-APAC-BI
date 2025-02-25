USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_luasertype2_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_luasertype2_audtc](
	[luasertype2id] [int] NOT NULL,
	[asertype2] [nvarchar](70) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
