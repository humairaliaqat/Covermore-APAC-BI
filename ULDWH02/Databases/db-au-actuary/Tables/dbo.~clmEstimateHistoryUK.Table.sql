USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~clmEstimateHistoryUK]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~clmEstimateHistoryUK](
	[CountryKey] [varchar](2) NOT NULL,
	[EstimateHistoryKey] [varchar](40) NOT NULL,
	[EstimateHistoryID] [int] NOT NULL,
	[EHSectionID] [int] NULL,
	[EHEstimateValue] [money] NULL,
	[EHCreateDate] [datetime] NULL,
	[EHCreatedByID] [int] NULL,
	[ClaimKey] [varchar](40) NULL,
	[SectionKey] [varchar](40) NULL,
	[EHCreatedBy] [nvarchar](150) NULL,
	[EHRecoveryEstimateValue] [money] NULL,
	[BIRowID] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[EHCreateDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
