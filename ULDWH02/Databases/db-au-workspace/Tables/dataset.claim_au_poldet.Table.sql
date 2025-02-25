USE [db-au-workspace]
GO
/****** Object:  Table [dataset].[claim_au_poldet]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataset].[claim_au_poldet](
	[date] [smalldatetime] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ClaimNo] [int] NOT NULL,
	[ClaimValue] [decimal](38, 6) NULL,
	[AgencySuperGroupName] [nvarchar](25) NULL,
	[GrossPremium] [money] NULL,
	[rnk] [bigint] NULL
) ON [PRIMARY]
GO
