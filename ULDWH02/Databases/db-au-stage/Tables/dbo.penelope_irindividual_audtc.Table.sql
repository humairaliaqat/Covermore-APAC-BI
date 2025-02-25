USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irindividual_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irindividual_audtc](
	[kindid] [int] NOT NULL,
	[kbookitemid] [int] NOT NULL,
	[indfirstname] [nvarchar](25) NOT NULL,
	[indmidint] [nchar](2) NULL,
	[indlastname] [nvarchar](25) NOT NULL,
	[indaddress1] [nvarchar](60) NULL,
	[indaddress2] [nvarchar](60) NULL,
	[indcity] [nvarchar](20) NULL,
	[luindprovstateid] [int] NULL,
	[luindcountryid] [int] NULL,
	[indpczip] [nvarchar](12) NULL,
	[luindgenderid] [int] NOT NULL,
	[inddateofbirth] [datetime2](7) NOT NULL,
	[lureferralid] [int] NULL,
	[indnotes] [ntext] NULL,
	[indenglish] [varchar](5) NULL,
	[luindlanguageid] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[indssn] [nvarchar](25) NULL,
	[indnii] [nvarchar](25) NULL,
	[ktaxschedid] [int] NULL,
	[lutitleid] [int] NULL,
	[kpmcid] [int] NULL,
	[indpin] [ntext] NULL,
	[indsecretques] [ntext] NULL,
	[indsecretans] [ntext] NULL,
	[inddvissues] [varchar](5) NULL,
	[indpartneraware] [varchar](5) NULL,
	[indhomeaware] [varchar](5) NULL,
	[indcounty] [nvarchar](50) NULL,
	[indfinconcern] [varchar](5) NOT NULL,
	[indfinconcerntext] [ntext] NULL,
	[inddvissuestext] [ntext] NULL,
	[luindmuethnicityid] [int] NULL,
	[luindmulanguageid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
