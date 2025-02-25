USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sabbtype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sabbtype_audtc](
	[kbbtypeid] [int] NOT NULL,
	[bbtype] [nvarchar](50) NOT NULL,
	[isorg] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[hascms] [varchar](5) NOT NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
