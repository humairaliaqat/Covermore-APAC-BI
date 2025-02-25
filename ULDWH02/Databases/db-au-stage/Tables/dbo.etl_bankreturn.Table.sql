USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_bankreturn]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_bankreturn](
	[CountryKey] [varchar](2) NOT NULL,
	[ReturnKey] [varchar](13) NULL,
	[AgencyKey] [varchar](10) NULL,
	[ReturnID] [int] NOT NULL,
	[AgencyCode] [varchar](7) NULL,
	[Op] [varchar](10) NULL,
	[Account] [varchar](4) NULL,
	[BankDate] [datetime] NULL,
	[BankTime] [datetime] NULL
) ON [PRIMARY]
GO
