USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpCommRate]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpCommRate](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpCommRate_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpCommRate_CountryKey] ON [dbo].[corpCommRate]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
