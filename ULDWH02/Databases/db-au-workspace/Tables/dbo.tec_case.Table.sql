USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_case]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_case](
	[Category] [varchar](27) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[CustomerID] [bigint] NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[CreateDate] [datetime] NULL,
	[Country] [nvarchar](25) NULL,
	[Protocol] [nvarchar](10) NOT NULL,
	[CaseType] [nvarchar](255) NULL,
	[IncidentType] [nvarchar](60) NULL,
	[RiskLevel] [nvarchar](50) NULL,
	[RiskReason] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
