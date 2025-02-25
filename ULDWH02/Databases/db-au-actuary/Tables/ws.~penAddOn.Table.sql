USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~penAddOn]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~penAddOn](
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
/****** Object:  Index [idx_penAddon_AddonKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penAddon_AddonKey] ON [ws].[~penAddOn]
(
	[AddOnKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAddon_AddonID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penAddon_AddonID] ON [ws].[~penAddOn]
(
	[AddOnID] ASC,
	[CountryKey] ASC,
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
