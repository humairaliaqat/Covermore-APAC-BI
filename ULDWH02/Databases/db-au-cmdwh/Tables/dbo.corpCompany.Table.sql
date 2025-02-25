USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpCompany]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpCompany](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](10) NULL,
	[CompanyID] [int] NOT NULL,
	[CompanyName] [varchar](50) NULL,
	[Nature] [varchar](50) NULL,
	[ACN] [varchar](15) NULL,
	[ABN] [varchar](15) NULL,
	[Street] [varchar](100) NULL,
	[Suburb] [varchar](25) NULL,
	[State] [varchar](20) NULL,
	[PostCode] [varchar](10) NULL,
	[ITC] [float] NULL,
	[NotRenew] [bit] NULL,
	[Phone] [varchar](15) NULL,
	[Fax] [varchar](15) NULL,
	[Email] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpCompany_CompanyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpCompany_CompanyKey] ON [dbo].[corpCompany]
(
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
