USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_itreferralentry_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_itreferralentry_audtc](
	[kreferralentryid] [int] NOT NULL,
	[kreferralentryclassid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[kreferralreasonid] [int] NULL,
	[kbluebookid] [int] NULL,
	[referraldate] [date] NOT NULL,
	[clientneeds] [ntext] NULL,
	[clientinstructions] [ntext] NULL,
	[clientconsent] [varchar](5) NOT NULL,
	[referralclosedate] [date] NULL,
	[referralclose] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[isexit] [varchar](5) NOT NULL,
	[lureferralentryuserdef1id] [int] NULL,
	[kbbrefavailserid] [int] NULL,
	[kreferraloutcomeid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
