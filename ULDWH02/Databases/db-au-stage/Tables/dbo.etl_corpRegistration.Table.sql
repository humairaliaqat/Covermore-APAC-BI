USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpRegistration]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpRegistration](
	[CountryKey] [varchar](2) NOT NULL,
	[RegistrationKey] [varchar](33) NULL,
	[QuoteKey] [varchar](10) NULL,
	[EmployeeKey] [varchar](33) NULL,
	[RegistrationID] [int] NOT NULL,
	[QuoteID] [int] NOT NULL,
	[EmployeeID] [varchar](50) NULL,
	[DestinationTypeID] [int] NULL,
	[Destination] [varchar](150) NULL,
	[State] [varchar](5) NULL,
	[Email] [varchar](510) NULL,
	[IssueDate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[Duration] [int] NULL,
	[Status] [varchar](20) NOT NULL,
	[CancelDate] [datetime] NULL
) ON [PRIMARY]
GO
