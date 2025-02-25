USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fltBusinessUnits]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fltBusinessUnits](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessUnitID] [bigint] NULL,
	[BusinessName] [varchar](255) NULL,
	[Company] [varchar](50) NULL,
	[OpenDate] [date] NULL,
	[CloseDate] [date] NULL,
	[BusinessType] [varchar](50) NULL,
	[T3Code] [varchar](15) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletKey] [varchar](33) NULL,
	[PseudoCode] [varchar](15) NULL,
	[Suburb] [varchar](100) NULL,
	[State] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[PostCode] [varchar](10) NULL,
	[FCBrand] [varchar](100) NULL,
	[FCDisipline] [varchar](100) NULL,
	[FCVillage] [varchar](100) NULL,
	[FCDivision] [varchar](100) NULL,
	[FCRegion] [varchar](100) NULL,
	[FCCountry] [varchar](100) NULL,
	[DataDate] [date] NULL,
	[FileDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_fltBusinessUnits_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_fltBusinessUnits_BIRowID] ON [dbo].[fltBusinessUnits]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_fltBusinessUnits_BusinessUnitID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_fltBusinessUnits_BusinessUnitID] ON [dbo].[fltBusinessUnits]
(
	[BusinessUnitID] ASC
)
INCLUDE([AlphaCode],[OutletKey],[DataDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
