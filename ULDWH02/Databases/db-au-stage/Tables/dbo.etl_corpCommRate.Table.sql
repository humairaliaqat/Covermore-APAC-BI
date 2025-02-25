USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpCommRate]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpCommRate](
	[CountryKey] [varchar](2) NOT NULL,
	[CommRateKey] [varchar](10) NULL,
	[CommRateID] [smallint] NOT NULL,
	[AgencyGroupCode] [varchar](2) NULL,
	[AgencyGroupName] [varchar](10) NULL,
	[CMCommissionRate] [float] NULL,
	[AgentCommissionRate] [float] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[OverrideCommissionRate] [float] NULL
) ON [PRIMARY]
GO
