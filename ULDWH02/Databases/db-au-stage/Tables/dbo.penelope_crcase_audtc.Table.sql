USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_crcase_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_crcase_audtc](
	[kcaseid] [int] NOT NULL,
	[casnickname] [nvarchar](35) NOT NULL,
	[kcasestatusid] [int] NOT NULL,
	[cassetting] [varchar](5) NULL,
	[cashouseinc] [numeric](7, 0) NOT NULL,
	[lucasrelstatusid] [int] NULL,
	[lucasfamilystatusid] [int] NULL,
	[casreldate] [date] NULL,
	[casblendedf] [varchar](5) NULL,
	[casotherinhome] [varchar](5) NULL,
	[casaccomodations] [nvarchar](50) NULL,
	[casneap1] [varchar](5) NULL,
	[lucasjobimpactid] [int] NULL,
	[lucasthreatid] [int] NULL,
	[casfamilysize] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[fileno] [ntext] NULL,
	[slogmodforreal] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
