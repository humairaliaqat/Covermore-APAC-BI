USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_policy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_policy](
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[TripStart] [date] NULL,
	[TripEnd] [date] NULL,
	[TravellerCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_trip]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_trip] ON [dbo].[tec_policy]
(
	[TripStart] ASC,
	[TripEnd] ASC
)
INCLUDE([TravellerCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
