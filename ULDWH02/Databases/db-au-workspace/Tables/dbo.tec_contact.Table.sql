USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_contact]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_contact](
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[TripStart] [date] NULL,
	[TripEnd] [date] NULL,
	[CustomerID] [bigint] NULL,
	[ContactType] [varchar](50) NULL,
	[ContactReference] [varchar](50) NULL,
	[ContactFirstDate] [date] NULL,
	[EventDate] [date] NULL,
	[ContactReason] [varchar](150) NULL,
	[ContactReasonType] [varchar](150) NULL,
	[ContactCount] [int] NULL
) ON [PRIMARY]
GO
