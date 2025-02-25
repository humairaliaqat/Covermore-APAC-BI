USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAddOn]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAddOn](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AddOnKey] [varchar](41) NULL,
	[AddOnID] [int] NULL,
	[DomainID] [int] NULL,
	[AddOnTypeID] [int] NULL,
	[AddOnCode] [nvarchar](50) NULL,
	[AddOnName] [nvarchar](50) NULL,
	[AllowMultiple] [bit] NULL,
	[DisplayName] [nvarchar](100) NULL,
	[isRateCardBased] [bit] NULL,
	[AddOnGroupID] [int] NULL,
	[ControlLabel] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[AddOnControlTypeID] [int] NULL,
	[DefaultValue] [nvarchar](50) NULL,
	[isMandatory] [bit] NOT NULL,
	[DomainKey] [varchar](41) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAddOn_AddOnKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penAddOn_AddOnKey] ON [dbo].[penAddOn]
(
	[AddOnKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAddOn_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penAddOn_CountryKey] ON [dbo].[penAddOn]
(
	[CountryKey] ASC,
	[CompanyKey] ASC,
	[AddOnID] ASC
)
INCLUDE([AddOnCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
