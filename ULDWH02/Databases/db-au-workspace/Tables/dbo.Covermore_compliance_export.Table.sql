USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Covermore_compliance_export]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Covermore_compliance_export](
	[Survey ID] [int] NULL,
	[Unit] [nvarchar](100) NULL,
	[First name] [nvarchar](100) NULL,
	[Last name] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Policy Number] [nvarchar](100) NULL,
	[Covermore Brand] [nvarchar](100) NULL,
	[Journey and Touchpoints] [nvarchar](100) NULL,
	[Likelihood to Recommend] [nvarchar](100) NULL,
	[Reason for Likelihood to Recommend Score] [nvarchar](100) NULL,
	[Non Purchasers Improve Experience Comment] [nvarchar](100) NULL,
	[Additional Comment] [nvarchar](100) NULL,
	[Satisfaction with Outcome Comment] [nvarchar](100) NULL,
	[Created Date] [datetime] NULL,
	[File_Name] [varchar](500) NULL
) ON [PRIMARY]
GO
