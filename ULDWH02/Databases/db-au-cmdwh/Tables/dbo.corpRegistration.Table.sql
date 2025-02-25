USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpRegistration]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpRegistration](
	[CountryKey] [varchar](2) NOT NULL,
	[RegistrationKey] [varchar](41) NULL,
	[QuoteKey] [varchar](10) NULL,
	[EmployeeKey] [varchar](53) NULL,
	[RegistrationID] [int] NULL,
	[QuoteID] [int] NOT NULL,
	[EmpployeeID] [varchar](50) NULL,
	[DestinationTypeID] [int] NULL,
	[Destination] [varchar](150) NULL,
	[State] [varchar](5) NULL,
	[Email] [varchar](510) NULL,
	[Issuedate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[Duration] [int] NULL,
	[Status] [varchar](20) NULL,
	[CancelDate] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpRegistration_QuoteKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpRegistration_QuoteKey] ON [dbo].[corpRegistration]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpRegistration_RegistrationKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpRegistration_RegistrationKey] ON [dbo].[corpRegistration]
(
	[RegistrationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
