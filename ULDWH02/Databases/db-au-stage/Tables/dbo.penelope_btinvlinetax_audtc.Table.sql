USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btinvlinetax_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btinvlinetax_audtc](
	[kinvlineid] [int] NOT NULL,
	[ktaxrateid] [int] NOT NULL,
	[taxamt] [numeric](10, 2) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
