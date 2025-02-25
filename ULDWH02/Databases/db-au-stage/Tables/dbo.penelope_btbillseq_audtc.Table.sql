USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btbillseq_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btbillseq_audtc](
	[kpolicymemid] [int] NOT NULL,
	[kprogprovid] [int] NOT NULL,
	[billseq] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
