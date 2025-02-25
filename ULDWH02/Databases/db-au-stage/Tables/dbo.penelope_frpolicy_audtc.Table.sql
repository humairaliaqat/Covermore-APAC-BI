USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frpolicy_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frpolicy_audtc](
	[kpolicyid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[kpolicyclassid] [int] NOT NULL,
	[kpublicpolicyid] [int] NULL,
	[kpolicytypeid] [int] NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[policyname] [nvarchar](25) NULL,
	[policystatus] [varchar](5) NOT NULL,
	[policycon] [varchar](5) NOT NULL,
	[policycomments] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[polsign] [varchar](5) NOT NULL,
	[polaccept] [varchar](5) NOT NULL,
	[kpolicycontactid] [int] NULL,
	[poldisableffs] [varchar](5) NOT NULL,
	[polsigndate] [datetime2](7) NULL,
	[poldisablefeeovr] [varchar](5) NOT NULL,
	[poldisabless] [varchar](5) NOT NULL,
	[policyinclusive] [varchar](5) NOT NULL,
	[policycorp] [varchar](5) NOT NULL,
	[kbluebookidpolcontact] [int] NULL,
	[kpricelevelid] [int] NULL,
	[searchdepttreeforbillto] [varchar](5) NOT NULL,
	[payabletositeid] [int] NULL,
	[kinvoicecurrencysignid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
