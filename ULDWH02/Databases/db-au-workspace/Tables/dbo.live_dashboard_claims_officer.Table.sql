USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_claims_officer]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_claims_officer](
	[DisplayName] [varchar](450) NULL,
	[Department] [varchar](255) NULL,
	[Company] [varchar](255) NULL,
	[JobTitle] [varchar](255) NULL,
	[IndiaFlag] [int] NULL,
	[TLFlag] [int] NULL,
	[TeleFlag] [int] NULL,
	[AuditFlag] [int] NULL,
	[COFlag] [int] NULL,
	[CROFlag] [int] NULL,
	[OtherFlag] [int] NULL
) ON [PRIMARY]
GO
