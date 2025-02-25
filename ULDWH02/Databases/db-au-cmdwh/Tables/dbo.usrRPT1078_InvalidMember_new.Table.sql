USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT1078_InvalidMember_new]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT1078_InvalidMember_new](
	[CountryKey] [varchar](2) NULL,
	[PolicyKey] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[MemberNumber] [varchar](20) NULL,
	[NumericBody] [varchar](8) NULL,
	[CheckDigit] [varchar](1) NULL,
	[isValidMember] [int] NULL,
	[isPrimary] [int] NULL,
	[LastName] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[GrossPremium] [money] NULL,
	[Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
