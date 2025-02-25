USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_clmEstimateHistory]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_clmEstimateHistory](
	[CountryKey] [varchar](2) NULL,
	[EstimateHistoryKey] [varchar](33) NULL,
	[ClaimKey] [varchar](33) NULL,
	[SectionKey] [varchar](95) NULL,
	[EstimateHistoryID] [int] NOT NULL,
	[EHSectionID] [int] NULL,
	[EHEstimateValue] [money] NULL,
	[EHRecoveryEstimateValue] [money] NULL,
	[EHCreateDate] [datetime] NULL,
	[EHCreateDateTimeUTC] [datetime] NULL,
	[EHCreatedByID] [int] NULL,
	[EHCreatedBy] [varchar](30) NULL
) ON [PRIMARY]
GO
