USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssassesscalc_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssassesscalc_audtc](
	[kassesscalcid] [int] NOT NULL,
	[assesscalc] [nvarchar](100) NOT NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
