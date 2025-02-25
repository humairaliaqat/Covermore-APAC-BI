USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_nritem_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_nritem_audtc](
	[kitemid] [int] NOT NULL,
	[kitemtypeid] [int] NOT NULL,
	[itemname] [nvarchar](40) NOT NULL,
	[kuomid] [int] NOT NULL,
	[itemfee] [numeric](10, 2) NOT NULL,
	[procedurecode] [nvarchar](50) NULL,
	[nractive] [varchar](5) NOT NULL,
	[kitemclassid] [int] NOT NULL,
	[lunruser1id] [int] NULL,
	[lunruser2id] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[itemnameshort] [nvarchar](10) NOT NULL,
	[itemfeell] [numeric](10, 2) NOT NULL,
	[itemdisabless] [varchar](5) NULL,
	[ktaxschedid] [int] NULL,
	[nrnotes] [ntext] NULL,
	[modifier1] [nvarchar](35) NULL,
	[modifier2] [nvarchar](35) NULL,
	[modifier3] [nvarchar](35) NULL,
	[modifier4] [nvarchar](35) NULL,
	[kitemcontactid] [int] NULL,
	[ignorecovstatus] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
