USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletStore_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletStore_autp](
	[OutletStoreID] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Code] [varchar](10) NOT NULL,
	[OutletID] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[StoreType] [int] NULL
) ON [PRIMARY]
GO
