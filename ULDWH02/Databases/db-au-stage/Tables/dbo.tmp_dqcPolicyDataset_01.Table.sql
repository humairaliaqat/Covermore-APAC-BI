USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tmp_dqcPolicyDataset_01]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_dqcPolicyDataset_01](
	[ID] [int] NOT NULL,
	[TransactionDateTimeUTC] [datetime] NULL,
	[PolicyNumber] [nvarchar](50) NULL,
	[CountryCode] [nvarchar](2) NOT NULL,
	[TimeZoneCode] [nvarchar](50) NOT NULL,
	[JVCode] [nvarchar](10) NULL,
	[Channel] [nvarchar](50) NULL,
	[PolicyCount] [int] NOT NULL,
	[GrossPremium] [money] NOT NULL,
	[TotalCommission] [money] NULL,
	[OutletAlphaKey] [nvarchar](50) NULL
) ON [PRIMARY]
GO
