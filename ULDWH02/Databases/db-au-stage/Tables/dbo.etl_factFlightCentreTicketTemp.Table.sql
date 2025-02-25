USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factFlightCentreTicketTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factFlightCentreTicketTemp](
	[IssueMonth] [datetime] NULL,
	[DomainID] [int] NOT NULL,
	[OutletKey] [varchar](33) NOT NULL,
	[OutletAlphaKey] [varchar](33) NOT NULL,
	[FLInternationalTicketCount] [float] NOT NULL,
	[FLDomesticTicketCount] [float] NOT NULL,
	[CMInternationalPolicyCount] [float] NOT NULL,
	[CMDomesticPolicyCount] [float] NOT NULL
) ON [PRIMARY]
GO
