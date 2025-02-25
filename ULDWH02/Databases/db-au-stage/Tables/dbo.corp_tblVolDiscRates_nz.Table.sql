USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblVolDiscRates_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblVolDiscRates_nz](
	[ID] [int] NOT NULL,
	[VolLvl] [money] NULL,
	[VolDiscRate] [real] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
