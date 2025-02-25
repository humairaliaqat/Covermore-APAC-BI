USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penJobError]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penJobError](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](3) NULL,
	[JobErrorKey] [varchar](41) NULL,
	[JobKey] [varchar](41) NULL,
	[ID] [int] NULL,
	[JobID] [int] NULL,
	[Description] [varchar](max) NULL,
	[CreateDateTime] [datetime] NULL,
	[ErrorSource] [varchar](15) NULL,
	[DataID] [varchar](300) NOT NULL,
	[SourceData] [varchar](max) NULL,
	[DomainKey] [varchar](41) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penJobError_JobErrorKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penJobError_JobErrorKey] ON [dbo].[penJobError]
(
	[JobErrorKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [idx_penJobError_CreateDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penJobError_CreateDateTime] ON [dbo].[penJobError]
(
	[CreateDateTime] ASC
)
INCLUDE([DataID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penJobError_DataID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penJobError_DataID] ON [dbo].[penJobError]
(
	[DataID] ASC,
	[CreateDateTime] ASC
)
INCLUDE([JobKey],[CountryKey],[CompanyKey],[ID],[Description],[ErrorSource],[SourceData]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
