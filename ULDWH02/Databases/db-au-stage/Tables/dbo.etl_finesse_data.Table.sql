USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_finesse_data]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_finesse_data](
	[Insurer] [varchar](255) NULL,
	[Sample Number] [varchar](255) NULL,
	[Factor] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[Destination] [varchar](255) NULL,
	[International Domestic] [varchar](255) NULL,
	[Number of Travellers] [varchar](255) NULL,
	[Travel Group] [varchar](255) NULL,
	[Number of Adults] [varchar](255) NULL,
	[Number of Children] [varchar](255) NULL,
	[Age of oldest adult] [varchar](255) NULL,
	[Age of second oldest adult] [varchar](255) NULL,
	[Age of oldest dependent] [varchar](255) NULL,
	[Age of second oldest dependent] [varchar](255) NULL,
	[Age of third oldest dependent] [varchar](255) NULL,
	[Travel Duration] [varchar](255) NULL,
	[Travel Duration Bands] [varchar](255) NULL,
	[Destination Region] [varchar](255) NULL,
	[Lead Time] [varchar](255) NULL,
	[Profile] [varchar](255) NULL,
	[Age of oldest adult - Band] [varchar](255) NULL,
	[Age of second oldest adult - Band] [varchar](255) NULL,
	[Age of oldest dependent - Band] [varchar](255) NULL,
	[Age of second oldest dependent - Band] [varchar](255) NULL,
	[Age of third oldest dependent - Band] [varchar](255) NULL,
	[Travel Duration - Band] [varchar](255) NULL,
	[Lead time - Band] [varchar](255) NULL,
	[Single Multi Trip - Band] [varchar](255) NULL,
	[Sep-17 Premium] [varchar](255) NULL,
	[Sep-17 Timestamp] [varchar](255) NULL,
	[Sep-17 Notes] [varchar](8000) NULL,
	[Dec-17 Premium] [varchar](255) NULL,
	[Dec-17 Timestamp] [varchar](255) NULL,
	[Dec-17 Notes] [varchar](8000) NULL
) ON [PRIMARY]
GO
