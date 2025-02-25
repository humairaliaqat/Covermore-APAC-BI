USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frfunderdept_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frfunderdept_audtc](
	[kfunderdeptid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[department] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[departmentdesc] [nvarchar](200) NULL,
	[sloginby] [int] NOT NULL,
	[slogmodby] [int] NOT NULL,
	[departmentpop] [int] NULL,
	[departmentpopdate] [date] NULL,
	[lustatedeptid] [int] NOT NULL,
	[parentdeptid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
