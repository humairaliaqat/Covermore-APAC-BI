USE [db-au-stage]
GO
/****** Object:  Table [dbo].[CustomerOnBasePolicy]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerOnBasePolicy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[CustomerKey] [varchar](41) NULL,
	[CustomerID] [int] NULL,
	[Title] [varchar](6) NULL,
	[FirstName] [varchar](25) NULL,
	[Initial] [varchar](4) NULL,
	[LastName] [varchar](25) NULL,
	[DateOfBirth] [datetime] NULL,
	[AgeAtDateOfIssue] [int] NULL,
	[PersonIsAdult] [bit] NULL,
	[AddressStreet] [varchar](60) NULL,
	[AddressSuburb] [varchar](30) NULL,
	[AddressState] [varchar](20) NULL,
	[AddressPostCode] [varchar](6) NULL,
	[AddressCountry] [varchar](20) NULL,
	[Phone] [varchar](30) NULL,
	[WorkPhone] [varchar](30) NULL,
	[Email] [varchar](60) NULL,
	[isPrimary] [bit] NULL,
	[MemberNumber] [varchar](25) NULL,
	[ClientID] [varchar](35) NULL,
	[EMCPremiumAmount] [money] NULL
) ON [PRIMARY]
GO
