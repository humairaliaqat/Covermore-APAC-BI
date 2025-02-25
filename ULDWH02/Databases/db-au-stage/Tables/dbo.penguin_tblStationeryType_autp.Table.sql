USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblStationeryType_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblStationeryType_autp](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[IsProductStationery] [bit] NOT NULL,
	[DocumentType] [int] NULL,
	[ExcludeGroups] [varchar](4000) NULL,
	[LinkUrl] [varchar](200) NULL,
	[ApplicableProductCodes] [varchar](500) NULL,
	[QuantityGroupID] [int] NULL,
	[SortOrder] [int] NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
