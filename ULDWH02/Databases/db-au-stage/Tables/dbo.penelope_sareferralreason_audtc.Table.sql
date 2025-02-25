USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sareferralreason_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sareferralreason_audtc](
	[kreferralreasonid] [int] NOT NULL,
	[referralreason] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[valisactive] [varchar](5) NOT NULL,
	[kreferralreasonclassid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
