USE [db-au-cba-healix]
GO
/****** Object:  Table [dbo].[emcApplications]    Script Date: 20/02/2025 3:54:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcApplications](
	[sessionid] [varchar](max) NULL,
	[AssessmentID] [nvarchar](4000) NULL,
	[AssessmentDateUTC] [datetime] NULL,
	[AssessmentDateAusLocalTime] [datetime] NULL,
	[isDeclaredByOther] [nvarchar](4000) NULL,
	[HealixVersion] [nvarchar](4000) NULL,
	[HealixRegionID] [nvarchar](4000) NULL,
	[tier] [nvarchar](4000) NULL,
	[GrossPrice] [nvarchar](4000) NULL,
	[DisplayPrice] [nvarchar](4000) NULL,
	[VerisktotalRiskScore] [nvarchar](4000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
