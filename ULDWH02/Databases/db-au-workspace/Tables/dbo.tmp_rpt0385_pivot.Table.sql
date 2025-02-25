USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0385_pivot]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0385_pivot](
	[Row] [bigint] NULL,
	[PolicyKey] [varchar](41) NULL,
	[IssueDate] [datetime] NOT NULL,
	[isPrimary] [bit] NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[Suburb] [nvarchar](50) NULL,
	[PostCode] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL
) ON [PRIMARY]
GO
