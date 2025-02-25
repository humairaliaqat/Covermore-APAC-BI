USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_pragser_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_pragser_audtc](
	[kagserid] [int] NOT NULL,
	[kprogtypeid] [int] NOT NULL,
	[asername] [nvarchar](80) NOT NULL,
	[asernotes] [ntext] NULL,
	[aserstartdate] [date] NOT NULL,
	[aserenddate] [date] NULL,
	[aserstatus] [varchar](5) NOT NULL,
	[luasertype1] [int] NULL,
	[luasertype2] [int] NULL,
	[luasertype3] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[serglcode] [nvarchar](10) NULL,
	[luasertype4] [int] NULL,
	[revglcode] [nvarchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
