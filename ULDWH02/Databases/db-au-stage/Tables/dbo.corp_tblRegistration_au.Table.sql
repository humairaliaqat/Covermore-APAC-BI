USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblRegistration_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblRegistration_au](
	[RegistrationID] [int] NOT NULL,
	[QtID] [int] NOT NULL,
	[EmpID] [varchar](50) NULL,
	[DestTypeID] [int] NULL,
	[State] [varchar](5) NULL,
	[Email] [varchar](510) NULL,
	[Issuedate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[Duration] [int] NULL,
	[Status] [varchar](20) NOT NULL,
	[CancelDate] [datetime] NULL
) ON [PRIMARY]
GO
