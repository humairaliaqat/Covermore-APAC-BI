USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sauseravailtype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sauseravailtype_audtc](
	[kuseravailtypeid] [int] NOT NULL,
	[useravailtype] [nvarchar](50) NOT NULL,
	[kcolourid] [int] NOT NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
