USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factFlightCentreTicket]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factFlightCentreTicket](
	[DateSK] [varchar](8) NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[FLInternationalTicketCount] [float] NOT NULL,
	[FLDomesticTicketCount] [float] NOT NULL,
	[CMInternationalPolicyCount] [float] NOT NULL,
	[CMDomesticPolicyCount] [float] NOT NULL
) ON [PRIMARY]
GO
