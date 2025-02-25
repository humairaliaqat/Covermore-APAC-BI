USE [db-au-stage]
GO
/****** Object:  Table [dbo].[PENELOPE_schema_diff_table]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PENELOPE_schema_diff_table](
	[object_id_PROD] [int] NOT NULL,
	[object_name_PROD] [sysname] NULL,
	[column_id_PROD] [int] NOT NULL,
	[name_PROD] [sysname] NULL,
	[max_length_PROD] [smallint] NOT NULL,
	[precision_PROD] [tinyint] NOT NULL,
	[scale_PROD] [tinyint] NOT NULL,
	[is_nullable_PROD] [bit] NULL,
	[is_identity_PROD] [bit] NOT NULL,
	[object_id_SANDBOX] [int] NOT NULL,
	[object_name_SANDBOX] [sysname] NULL,
	[column_id_SANDBOX] [int] NOT NULL,
	[name_SANDBOX] [sysname] NULL,
	[max_length_SANDBOX] [smallint] NOT NULL,
	[precision_SANDBOX] [tinyint] NOT NULL,
	[scale_SANDBOX] [tinyint] NOT NULL,
	[is_nullable_SANDBOX] [bit] NULL,
	[is_identity_SANDBOX] [bit] NOT NULL
) ON [PRIMARY]
GO
