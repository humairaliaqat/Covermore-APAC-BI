USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[testtttt]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[testtttt](
	[GroupName] [nvarchar](50) NOT NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[ISO3Code] [varchar](3) NULL,
	[SellPrice] [money] NOT NULL,
	[ReportStartDate] [datetime] NULL,
	[ReportEndDate] [datetime] NULL,
	[TripType] [nvarchar](50) NULL,
	[NextPolicies] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
