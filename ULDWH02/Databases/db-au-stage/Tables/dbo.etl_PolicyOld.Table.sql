USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_PolicyOld]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_PolicyOld](
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyNo] [int] NOT NULL,
	[OldPolicyNo] [int] NULL,
	[OldPolicyType] [varchar](1) NOT NULL,
	[OldProductCode] [varchar](5) NULL,
	[OldPlanCode] [varchar](6) NULL
) ON [PRIMARY]
GO
