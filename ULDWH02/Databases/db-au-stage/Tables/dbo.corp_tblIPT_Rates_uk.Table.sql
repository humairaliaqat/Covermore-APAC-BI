USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblIPT_Rates_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblIPT_Rates_uk](
	[ID] [int] NOT NULL,
	[IPT_Rate] [float] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
