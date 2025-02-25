USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~FinesseData]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~FinesseData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Insurer] [varchar](200) NULL,
	[Sample Number] [varchar](50) NULL,
	[Factor] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Destination] [varchar](200) NULL,
	[International-Domestic] [varchar](50) NULL,
	[Number of Travellers] [int] NULL,
	[Travel Group] [varchar](50) NULL,
	[Number of Adults] [int] NULL,
	[Number of Children] [int] NULL,
	[Age of oldest adult] [int] NULL,
	[Age of second oldest adult] [int] NULL,
	[Age of oldest dependent] [int] NULL,
	[Age of second oldest dependent] [int] NULL,
	[Age of third oldest dependent] [int] NULL,
	[Travel Duration] [int] NULL,
	[Travel Duration Bands] [varchar](50) NULL,
	[Destination Region] [varchar](200) NULL,
	[Lead Time] [int] NULL,
	[Profile] [varchar](100) NULL,
	[Age of oldest adult - Band] [varchar](50) NULL,
	[Age of second oldest adult - Band] [varchar](50) NULL,
	[Age of oldest dependent - Band] [varchar](50) NULL,
	[Age of second oldest dependent - Band] [varchar](50) NULL,
	[Age of third oldest dependent - Band] [varchar](50) NULL,
	[Travel Duration - Band] [varchar](50) NULL,
	[Lead time - Band] [varchar](50) NULL,
	[Single Multi Trip - Band] [varchar](50) NULL,
	[Start Date] [datetime] NULL,
	[Start Date Premium] [numeric](18, 8) NULL,
	[Start Date Notes] [varchar](8000) NULL,
	[End Date] [datetime] NULL,
	[End Date Premium] [numeric](18, 8) NULL,
	[End Date Notes] [varchar](8000) NULL
) ON [PRIMARY]
GO
