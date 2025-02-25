USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ctprogprov_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ctprogprov_audtc](
	[kprogprovid] [int] NOT NULL,
	[kcaseid] [int] NOT NULL,
	[kcaseprogid] [int] NOT NULL,
	[kcworkshopid] [int] NULL,
	[kcworkeridprim] [int] NOT NULL,
	[kcworkeridsec] [int] NULL,
	[pprovstart] [date] NOT NULL,
	[pprovend] [date] NULL,
	[kprogprovstatusid] [int] NOT NULL,
	[pprovbookonly] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[ppfeeovr] [numeric](10, 2) NULL,
	[kppfunagreid] [int] NULL,
	[ppsessremind] [varchar](5) NULL,
	[ppdaysremind] [varchar](5) NULL,
	[kbillindid] [int] NULL,
	[kprogmemidpres] [int] NULL,
	[kactidreg] [int] NULL,
	[estimsessioncount] [int] NULL,
	[kbillindsecid] [int] NULL,
	[billindprimpercent] [numeric](5, 3) NULL,
	[luppclosereasonid] [int] NULL,
	[ppclosenotes] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
