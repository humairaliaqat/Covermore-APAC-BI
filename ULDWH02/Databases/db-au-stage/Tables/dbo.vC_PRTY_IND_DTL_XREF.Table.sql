USE [db-au-stage]
GO
/****** Object:  Table [dbo].[vC_PRTY_IND_DTL_XREF]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[vC_PRTY_IND_DTL_XREF](
	[ROWID_XREF] [bigint] NOT NULL,
	[ROWID_OBJECT] [nchar](14) NOT NULL,
	[ORIG_ROWID_OBJECT] [nchar](14) NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
