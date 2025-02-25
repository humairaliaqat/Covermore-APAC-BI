USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_CMTravellersData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_CMTravellersData](
	[DistributionType] [nvarchar](255) NOT NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[AgencyGroup] [nvarchar](103) NOT NULL,
	[Month] [datetime] NULL,
	[FYear] [varchar](33) NULL,
	[CYear] [int] NULL,
	[DurationGroup] [varchar](10) NOT NULL,
	[AgeGroup] [varchar](7) NOT NULL,
	[TravellersCount] [int] NULL
) ON [PRIMARY]
GO
