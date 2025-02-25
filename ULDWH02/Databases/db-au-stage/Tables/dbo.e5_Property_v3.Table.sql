USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Property_v3]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Property_v3](
	[Id] [nvarchar](32) NOT NULL,
	[PropertyLabel] [nvarchar](100) NOT NULL,
	[PropertyType] [int] NOT NULL,
	[DataType] [int] NOT NULL,
	[List_Id] [int] NOT NULL,
	[Lookup_Id] [int] NOT NULL,
	[Lookup_Field] [nvarchar](100) NOT NULL,
	[Lookup_FieldType] [int] NOT NULL,
	[Currency_Id] [int] NOT NULL,
	[DefaultValue] [varchar](512) NULL,
	[FormLibraryUrl] [nvarchar](200) NOT NULL,
	[FormTemplateUrl] [nvarchar](200) NOT NULL,
	[FormX] [int] NOT NULL,
	[FormY] [int] NOT NULL,
	[FormW] [int] NOT NULL,
	[FormH] [int] NOT NULL,
	[PopulateFromFormPropertyId] [nvarchar](32) NULL,
	[PopulateFromFormXPath] [nvarchar](1000) NULL,
	[PreProcessorAssemblyName] [varchar](256) NULL,
	[PreProcessorClassName] [varchar](256) NULL,
	[PreProcessorMethodName] [varchar](256) NULL,
	[PostProcessorAssemblyName] [varchar](256) NULL,
	[PostProcessorClassName] [varchar](256) NULL,
	[PostProcessorMethodName] [varchar](256) NULL,
	[CaseNoteTypeId] [int] NULL,
	[ViewFormInPrintWindow] [bit] NULL,
	[MaxLength] [int] NULL,
	[Lookup_DataType] [int] NOT NULL,
	[LinkImageUrl] [nvarchar](100) NULL,
	[LinkText] [nvarchar](100) NULL,
	[LinkProperties] [nvarchar](2000) NULL,
	[IsExportable] [bit] NOT NULL,
	[Tooltip] [nvarchar](250) NULL,
	[ExternalId] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedDateTime] [datetime2](7) NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[Styles] [varchar](500) NULL,
	[CssClass] [varchar](50) NULL,
	[Attributes] [varchar](1000) NULL,
	[ValueExpression] [nvarchar](1000) NULL,
	[AllowInvalidLookupKey] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [e5_Property_v31]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_Property_v31] ON [dbo].[e5_Property_v3]
(
	[PropertyLabel] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
