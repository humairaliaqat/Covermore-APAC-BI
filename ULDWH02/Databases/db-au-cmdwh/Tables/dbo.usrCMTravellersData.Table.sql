USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCMTravellersData]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCMTravellersData](
	[DistributionType] [nvarchar](100) NULL,
	[SuperGroupName] [nvarchar](50) NULL,
	[AgencyGroup] [nvarchar](200) NULL,
	[Month] [datetime] NULL,
	[FYear] [nvarchar](10) NULL,
	[CYear] [int] NULL,
	[DurationGroup] [nvarchar](20) NULL,
	[AgeGroup] [nvarchar](10) NULL,
	[TravellersCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrCMTravellersData_Month]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrCMTravellersData_Month] ON [dbo].[usrCMTravellersData]
(
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
