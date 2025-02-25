USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Property_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Property_au](
	[Id] [nvarchar](32) NOT NULL,
	[PropertyLabel] [nvarchar](100) NOT NULL,
	[PropertyType] [int] NOT NULL,
	[DataType] [int] NOT NULL,
	[List_Id] [int] NOT NULL,
	[Lookup_Id] [int] NOT NULL,
	[Lookup_Field] [nvarchar](100) NOT NULL,
	[Lookup_FieldType] [int] NOT NULL,
	[Currency_Id] [int] NOT NULL,
	[DefaultValue] [nvarchar](100) NULL,
	[FormLibraryUrl] [nvarchar](200) NOT NULL,
	[FormTemplateUrl] [nvarchar](200) NOT NULL,
	[FormX] [int] NOT NULL,
	[FormY] [int] NOT NULL,
	[FormW] [int] NOT NULL,
	[FormH] [int] NOT NULL,
	[PopulateFromFormPropertyId] [nvarchar](32) NULL,
	[PopulateFromFormXPath] [nvarchar](1000) NULL,
	[PreProcessorAssemblyName] [nvarchar](200) NULL,
	[PreProcessorClassName] [nvarchar](100) NULL,
	[PreProcessorMethodName] [nvarchar](100) NULL,
	[PostProcessorAssemblyName] [nvarchar](200) NULL,
	[PostProcessorClassName] [nvarchar](100) NULL,
	[PostProcessorMethodName] [nvarchar](100) NULL,
	[CaseNoteTypeId] [int] NULL,
	[ViewFormInPrintWindow] [bit] NULL,
	[Width] [nvarchar](16) NULL,
	[MaxLength] [int] NULL,
	[Lookup_DataType] [int] NOT NULL,
	[LinkImageUrl] [nvarchar](100) NULL,
	[LinkText] [nvarchar](100) NULL,
	[LinkProperties] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
