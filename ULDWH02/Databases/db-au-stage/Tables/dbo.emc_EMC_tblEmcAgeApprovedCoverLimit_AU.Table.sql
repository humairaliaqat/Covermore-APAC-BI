USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblEmcAgeApprovedCoverLimit_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblEmcAgeApprovedCoverLimit_AU](
	[Counter] [int] NOT NULL,
	[AreaMappingID] [int] NULL,
	[MinAge] [int] NULL,
	[MaxAge] [int] NULL,
	[MaxCover] [numeric](18, 2) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [nvarchar](100) NULL
) ON [PRIMARY]
GO
