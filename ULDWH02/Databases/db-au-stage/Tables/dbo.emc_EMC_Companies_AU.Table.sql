USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_Companies_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_Companies_AU](
	[Compid] [smallint] NOT NULL,
	[ProdCode] [varchar](3) NULL,
	[Product] [varchar](50) NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[EmailTemplate] [varchar](255) NULL,
	[Phone] [varchar](30) NULL,
	[BCC] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[FromEmail] [varchar](255) NULL,
	[Fax] [varchar](30) NULL,
	[Logo] [varchar](255) NULL,
	[Color] [varchar](10) NULL,
	[CompanyCode] [varchar](50) NULL,
	[HealixBaseURL] [varchar](200) NULL,
	[ParentCompanyid] [int] NULL,
	[HealixOnly] [int] NULL,
	[Domainid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_Companies_AU_Compid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_Companies_AU_Compid] ON [dbo].[emc_EMC_Companies_AU]
(
	[Compid] ASC
)
INCLUDE([ParentCompanyid],[Domainid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
