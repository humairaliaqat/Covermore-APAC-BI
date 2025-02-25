USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblRegion_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblRegion_uscm](
	[RegionId] [int] NOT NULL,
	[DomainId] [int] NULL,
	[Region] [nvarchar](50) NULL,
	[TimeZoneId] [smallint] NULL
) ON [PRIMARY]
GO
