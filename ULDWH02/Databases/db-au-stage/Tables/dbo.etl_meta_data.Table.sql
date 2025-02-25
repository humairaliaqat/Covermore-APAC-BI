USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_meta_data]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_meta_data](
	[Country] [varchar](255) NULL,
	[isActive] [varchar](255) NULL,
	[SourceServerName] [varchar](255) NULL,
	[SourceDatabaseName] [varchar](255) NULL,
	[SourceSchema] [varchar](255) NULL,
	[SourceTableName] [varchar](255) NULL,
	[FileFormatPath] [varchar](255) NULL,
	[FileFormatName] [varchar](255) NULL,
	[FileFormatExt] [varchar](255) NULL,
	[OutputFilePath] [varchar](255) NULL,
	[OutputFileName] [varchar](255) NULL,
	[OutputFileExt] [varchar](255) NULL,
	[ErrFilePath] [varchar](255) NULL,
	[ErrFilePrefix] [varchar](255) NULL,
	[TableType] [varchar](255) NULL,
	[DateColumn] [varchar](255) NULL,
	[TargetServerName] [varchar](255) NULL,
	[TargetDatabaseName] [varchar](255) NULL,
	[TargetTableName] [varchar](255) NULL,
	[BCP_FFSwitches] [varchar](255) NULL,
	[BCP_ExportSwitches] [varchar](255) NULL,
	[BCP_ImportSwitches] [varchar](255) NULL,
	[BCP_ExportQuery] [varchar](4000) NULL,
	[BCP_FFCommand] [varchar](4000) NULL,
	[BCP_ExportCommand] [varchar](4000) NULL,
	[BCP_ImportCommand] [varchar](4000) NULL,
	[SQL_CreateTableDef] [varchar](4000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ClusteredIndex-20241105-213512]    Script Date: 24/02/2025 5:08:04 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20241105-213512] ON [dbo].[etl_meta_data]
(
	[SourceTableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20241105-213816]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20241105-213816] ON [dbo].[etl_meta_data]
(
	[TableType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
