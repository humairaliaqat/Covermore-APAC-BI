USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[RPT1078_Policy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPT1078_Policy](
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[MemberNumber] [nvarchar](4000) NULL,
	[NumericBody] [nvarchar](8) NULL,
	[CheckDigit] [nvarchar](1) NULL,
	[isValidMember] [int] NOT NULL,
	[isPrimary] [bit] NULL,
	[LastName] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NULL,
	[GrossPremium] [money] NULL
) ON [PRIMARY]
GO
