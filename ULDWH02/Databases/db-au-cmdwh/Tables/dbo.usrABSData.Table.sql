USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrABSData]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrABSData](
	[Month] [datetime] NULL,
	[FYear] [varchar](7) NULL,
	[CYear] [int] NULL,
	[DurationGroup] [nvarchar](50) NULL,
	[AgeGroup] [nvarchar](50) NULL,
	[Country] [nvarchar](200) NULL,
	[CountryGroup] [nvarchar](200) NULL,
	[Reason] [nvarchar](100) NULL,
	[TravellersCount] [int] NULL,
	[TravellersCountRLTM] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrABSData_Month]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_usrABSData_Month] ON [dbo].[usrABSData]
(
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
