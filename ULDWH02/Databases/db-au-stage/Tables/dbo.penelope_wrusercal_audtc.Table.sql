USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wrusercal_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wrusercal_audtc](
	[kusercalid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[usercaleffdate] [date] NOT NULL,
	[usercalname] [nvarchar](50) NOT NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[usercalenddate] [date] NULL
) ON [PRIMARY]
GO
