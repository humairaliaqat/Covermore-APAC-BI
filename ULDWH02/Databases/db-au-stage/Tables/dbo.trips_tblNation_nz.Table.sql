USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tblNation_nz]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tblNation_nz](
	[Nationid] [tinyint] NOT NULL,
	[EGMNationid] [tinyint] NULL,
	[Nation_Name] [varchar](100) NULL
) ON [PRIMARY]
GO
