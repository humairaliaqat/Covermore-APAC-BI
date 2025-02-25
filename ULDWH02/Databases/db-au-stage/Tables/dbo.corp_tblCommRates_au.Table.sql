USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblCommRates_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblCommRates_au](
	[ID] [smallint] NOT NULL,
	[AgtGroup] [varchar](2) NULL,
	[GrpDesc] [varchar](10) NULL,
	[CMCommRate] [float] NULL,
	[AgtCommRate] [float] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[OverrideCommRate] [float] NULL
) ON [PRIMARY]
GO
