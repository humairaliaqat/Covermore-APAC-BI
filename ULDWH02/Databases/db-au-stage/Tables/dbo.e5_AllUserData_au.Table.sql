USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_AllUserData_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_AllUserData_au](
	[tp_ID] [int] NOT NULL,
	[tp_ListId] [uniqueidentifier] NOT NULL,
	[tp_SiteId] [uniqueidentifier] NOT NULL,
	[tp_RowOrdinal] [int] NOT NULL,
	[tp_Version] [int] NOT NULL,
	[tp_Author] [int] NULL,
	[tp_Editor] [int] NULL,
	[tp_Modified] [datetime] NULL,
	[tp_Created] [datetime] NULL,
	[tp_Ordering] [varchar](512) NULL,
	[tp_ThreadIndex] [varbinary](512) NULL,
	[tp_HasAttachment] [bit] NOT NULL,
	[tp_ModerationStatus] [int] NOT NULL,
	[tp_IsCurrent] [bit] NOT NULL,
	[tp_ItemOrder] [float] NULL,
	[tp_InstanceID] [int] NULL,
	[tp_GUID] [uniqueidentifier] NOT NULL,
	[tp_CopySource] [nvarchar](260) NULL,
	[tp_HasCopyDestinations] [bit] NULL,
	[tp_AuditFlags] [int] NULL,
	[tp_InheritAuditFlags] [int] NULL,
	[tp_Size] [int] NOT NULL,
	[tp_WorkflowVersion] [int] NULL,
	[tp_WorkflowInstanceID] [uniqueidentifier] NULL,
	[tp_DirName] [nvarchar](256) NOT NULL,
	[tp_LeafName] [nvarchar](128) NOT NULL,
	[tp_DeleteTransactionId] [varbinary](16) NOT NULL,
	[tp_ContentType] [nvarchar](255) NULL,
	[tp_ContentTypeId] [varbinary](512) NULL,
	[nvarchar1] [nvarchar](255) NULL,
	[nvarchar2] [nvarchar](255) NULL,
	[nvarchar3] [nvarchar](255) NULL,
	[nvarchar4] [nvarchar](255) NULL,
	[nvarchar5] [nvarchar](255) NULL,
	[nvarchar6] [nvarchar](255) NULL,
	[nvarchar7] [nvarchar](255) NULL,
	[nvarchar8] [nvarchar](255) NULL,
	[ntext1] [ntext] NULL,
	[ntext2] [ntext] NULL,
	[ntext3] [ntext] NULL,
	[ntext4] [ntext] NULL,
	[sql_variant1] [sql_variant] NULL,
	[nvarchar9] [nvarchar](255) NULL,
	[nvarchar10] [nvarchar](255) NULL,
	[nvarchar11] [nvarchar](255) NULL,
	[nvarchar12] [nvarchar](255) NULL,
	[nvarchar13] [nvarchar](255) NULL,
	[nvarchar14] [nvarchar](255) NULL,
	[nvarchar15] [nvarchar](255) NULL,
	[nvarchar16] [nvarchar](255) NULL,
	[ntext5] [ntext] NULL,
	[ntext6] [ntext] NULL,
	[ntext7] [ntext] NULL,
	[ntext8] [ntext] NULL,
	[sql_variant2] [sql_variant] NULL,
	[nvarchar17] [nvarchar](255) NULL,
	[nvarchar18] [nvarchar](255) NULL,
	[nvarchar19] [nvarchar](255) NULL,
	[nvarchar20] [nvarchar](255) NULL,
	[nvarchar21] [nvarchar](255) NULL,
	[nvarchar22] [nvarchar](255) NULL,
	[nvarchar23] [nvarchar](255) NULL,
	[nvarchar24] [nvarchar](255) NULL,
	[ntext9] [ntext] NULL,
	[ntext10] [ntext] NULL,
	[ntext11] [ntext] NULL,
	[ntext12] [ntext] NULL,
	[sql_variant3] [sql_variant] NULL,
	[nvarchar25] [nvarchar](255) NULL,
	[nvarchar26] [nvarchar](255) NULL,
	[nvarchar27] [nvarchar](255) NULL,
	[nvarchar28] [nvarchar](255) NULL,
	[nvarchar29] [nvarchar](255) NULL,
	[nvarchar30] [nvarchar](255) NULL,
	[nvarchar31] [nvarchar](255) NULL,
	[nvarchar32] [nvarchar](255) NULL,
	[ntext13] [ntext] NULL,
	[ntext14] [ntext] NULL,
	[ntext15] [ntext] NULL,
	[ntext16] [ntext] NULL,
	[sql_variant4] [sql_variant] NULL,
	[nvarchar33] [nvarchar](255) NULL,
	[nvarchar34] [nvarchar](255) NULL,
	[nvarchar35] [nvarchar](255) NULL,
	[nvarchar36] [nvarchar](255) NULL,
	[nvarchar37] [nvarchar](255) NULL,
	[nvarchar38] [nvarchar](255) NULL,
	[nvarchar39] [nvarchar](255) NULL,
	[nvarchar40] [nvarchar](255) NULL,
	[ntext17] [ntext] NULL,
	[ntext18] [ntext] NULL,
	[ntext19] [ntext] NULL,
	[ntext20] [ntext] NULL,
	[sql_variant5] [sql_variant] NULL,
	[nvarchar41] [nvarchar](255) NULL,
	[nvarchar42] [nvarchar](255) NULL,
	[nvarchar43] [nvarchar](255) NULL,
	[nvarchar44] [nvarchar](255) NULL,
	[nvarchar45] [nvarchar](255) NULL,
	[nvarchar46] [nvarchar](255) NULL,
	[nvarchar47] [nvarchar](255) NULL,
	[nvarchar48] [nvarchar](255) NULL,
	[ntext21] [ntext] NULL,
	[ntext22] [ntext] NULL,
	[ntext23] [ntext] NULL,
	[ntext24] [ntext] NULL,
	[sql_variant6] [sql_variant] NULL,
	[nvarchar49] [nvarchar](255) NULL,
	[nvarchar50] [nvarchar](255) NULL,
	[nvarchar51] [nvarchar](255) NULL,
	[nvarchar52] [nvarchar](255) NULL,
	[nvarchar53] [nvarchar](255) NULL,
	[nvarchar54] [nvarchar](255) NULL,
	[nvarchar55] [nvarchar](255) NULL,
	[nvarchar56] [nvarchar](255) NULL,
	[ntext25] [ntext] NULL,
	[ntext26] [ntext] NULL,
	[ntext27] [ntext] NULL,
	[ntext28] [ntext] NULL,
	[sql_variant7] [sql_variant] NULL,
	[nvarchar57] [nvarchar](255) NULL,
	[nvarchar58] [nvarchar](255) NULL,
	[nvarchar59] [nvarchar](255) NULL,
	[nvarchar60] [nvarchar](255) NULL,
	[nvarchar61] [nvarchar](255) NULL,
	[nvarchar62] [nvarchar](255) NULL,
	[nvarchar63] [nvarchar](255) NULL,
	[nvarchar64] [nvarchar](255) NULL,
	[ntext29] [ntext] NULL,
	[ntext30] [ntext] NULL,
	[ntext31] [ntext] NULL,
	[ntext32] [ntext] NULL,
	[sql_variant8] [sql_variant] NULL,
	[int1] [int] NULL,
	[int2] [int] NULL,
	[int3] [int] NULL,
	[int4] [int] NULL,
	[int5] [int] NULL,
	[int6] [int] NULL,
	[int7] [int] NULL,
	[int8] [int] NULL,
	[int9] [int] NULL,
	[int10] [int] NULL,
	[int11] [int] NULL,
	[int12] [int] NULL,
	[int13] [int] NULL,
	[int14] [int] NULL,
	[int15] [int] NULL,
	[int16] [int] NULL,
	[float1] [float] NULL,
	[float2] [float] NULL,
	[float3] [float] NULL,
	[float4] [float] NULL,
	[float5] [float] NULL,
	[float6] [float] NULL,
	[float7] [float] NULL,
	[float8] [float] NULL,
	[float9] [float] NULL,
	[float10] [float] NULL,
	[float11] [float] NULL,
	[float12] [float] NULL,
	[datetime1] [datetime] NULL,
	[datetime2] [datetime] NULL,
	[datetime3] [datetime] NULL,
	[datetime4] [datetime] NULL,
	[datetime5] [datetime] NULL,
	[datetime6] [datetime] NULL,
	[datetime7] [datetime] NULL,
	[datetime8] [datetime] NULL,
	[bit1] [bit] NULL,
	[bit2] [bit] NULL,
	[bit3] [bit] NULL,
	[bit4] [bit] NULL,
	[bit5] [bit] NULL,
	[bit6] [bit] NULL,
	[bit7] [bit] NULL,
	[bit8] [bit] NULL,
	[bit9] [bit] NULL,
	[bit10] [bit] NULL,
	[bit11] [bit] NULL,
	[bit12] [bit] NULL,
	[bit13] [bit] NULL,
	[bit14] [bit] NULL,
	[bit15] [bit] NULL,
	[bit16] [bit] NULL,
	[uniqueidentifier1] [uniqueidentifier] NULL,
	[tp_Level] [tinyint] NOT NULL,
	[tp_IsCurrentVersion] [bit] NOT NULL,
	[tp_UIVersion] [int] NOT NULL,
	[tp_CalculatedVersion] [int] NOT NULL,
	[tp_UIVersionString] [nvarchar](61) NULL,
	[tp_DraftOwnerId] [int] NULL,
	[tp_CheckoutUserId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
