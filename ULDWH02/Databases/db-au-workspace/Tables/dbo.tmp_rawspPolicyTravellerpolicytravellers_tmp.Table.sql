USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rawspPolicyTravellerpolicytravellers_tmp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rawspPolicyTravellerpolicytravellers_tmp](
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[IssueDate] [datetime] NOT NULL,
	[GroupCode] [nvarchar](50) NOT NULL,
	[PolicyTravellerID] [int] NOT NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[isPrimary] [bit] NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[isAdult] [bit] NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[Street] [nvarchar](201) NULL,
	[Suburb] [nvarchar](50) NULL,
	[Postcode] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[HomeMobilePhone] [varchar](50) NOT NULL,
	[WorkPhone] [varchar](50) NULL,
	[OptFurtherContact] [bit] NULL,
	[EMCReference] [varchar](100) NULL,
	[EMCType] [nvarchar](100) NULL,
	[isRepeatCustomer] [int] NOT NULL,
	[PIDValue] [nvarchar](256) NULL
) ON [PRIMARY]
GO
