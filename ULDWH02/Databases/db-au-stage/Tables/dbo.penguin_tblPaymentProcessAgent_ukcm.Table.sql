USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentProcessAgent_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentProcessAgent_ukcm](
	[PaymentProcessAgentId] [tinyint] NOT NULL,
	[Name] [varchar](55) NOT NULL,
	[Code] [varchar](3) NOT NULL,
	[CompanyId] [tinyint] NOT NULL,
	[Status] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
