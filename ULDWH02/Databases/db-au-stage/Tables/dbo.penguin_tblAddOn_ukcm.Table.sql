USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOn_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOn_ukcm](
	[AddOnId] [int] NOT NULL,
	[DomainId] [int] NULL,
	[AddOnTypeId] [int] NULL,
	[AddOnCode] [nvarchar](50) NULL,
	[AddOnName] [nvarchar](50) NULL,
	[AllowMultiple] [bit] NULL,
	[DisplayName] [nvarchar](100) NULL,
	[IsRateCardBased] [bit] NOT NULL,
	[AddOnGroupId] [int] NULL,
	[ControlLabel] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[AddOnControlTypeID] [int] NULL,
	[DefaultValue] [nvarchar](50) NULL,
	[IsMandatory] [bit] NOT NULL,
	[COIAmmendmentDisplayName] [varchar](250) NULL,
	[COICancelTransactionDisplayName] [varchar](250) NULL,
	[QuoteTemplateDisplayName] [varchar](250) NULL,
	[TIPQuoteTemplateDisplayName] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblAddOn_ukcm_AddOnID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblAddOn_ukcm_AddOnID] ON [dbo].[penguin_tblAddOn_ukcm]
(
	[AddOnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
