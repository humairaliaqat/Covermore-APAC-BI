USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~UWSnapshot]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~UWSnapshot](
	[PolicyKey] [varchar](41) NULL,
	[Domain Country] [varchar](2) NULL,
	[Alpha Code] [nvarchar](20) NULL,
	[JV Code] [nvarchar](20) NULL,
	[Base Policy No] [varchar](50) NULL,
	[Issue Date] [datetime] NULL,
	[Posting Date] [datetime] NULL,
	[SnapshotDate] [varchar](10) NOT NULL,
	[GUG] [money] NULL,
	[Premium] [money] NULL,
	[UWPremium] [numeric](35, 14) NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_UWSnapshot] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
