USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Medallia_ComplianceFile]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_ComplianceFile](
	[surveyID] [int] NULL,
	[Customer_FirstName] [nvarchar](100) NULL,
	[Customer_LastName] [nvarchar](100) NULL,
	[Customer_Email] [nvarchar](100) NULL,
	[Brand] [nvarchar](100) NULL,
	[Touchpoint] [nvarchar](50) NULL,
	[NPS_Score] [nvarchar](10) NULL,
	[Free text] [nvarchar](max) NULL,
	[load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
