USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_adireferralentryassign_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_adireferralentryassign_audtc](
	[kreferralentryid] [int] NOT NULL,
	[kcomdocid] [int] NOT NULL,
	[delpropagate] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
