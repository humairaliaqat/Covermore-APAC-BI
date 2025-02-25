USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ent_C_PRTY_IND_DTL_aucm]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ent_C_PRTY_IND_DTL_aucm](
	[ROWID_OBJECT] [nchar](14) NOT NULL,
	[CREATOR] [nvarchar](50) NULL,
	[CREATE_DATE] [datetime2](7) NULL,
	[UPDATED_BY] [nvarchar](50) NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NULL,
	[CONSOLIDATION_IND] [bigint] NOT NULL,
	[DELETED_IND] [bigint] NULL,
	[DELETED_BY] [nvarchar](50) NULL,
	[DELETED_DATE] [datetime2](7) NULL,
	[LAST_ROWID_SYSTEM] [nchar](14) NOT NULL,
	[DIRTY_IND] [bigint] NULL,
	[INTERACTION_ID] [bigint] NULL,
	[HUB_STATE_IND] [bigint] NOT NULL,
	[CM_DIRTY_IND] [bigint] NULL,
	[PRTY_FK] [nchar](14) NOT NULL,
	[TITLE] [nvarchar](20) NULL,
	[FRST_NM] [nvarchar](100) NULL,
	[MID_NM] [nvarchar](100) NULL,
	[LST_NM] [nvarchar](100) NULL,
	[IND_NM] [nvarchar](255) NULL,
	[GNDR] [nvarchar](7) NULL,
	[MARITL_STS] [nvarchar](15) NULL,
	[DOB] [datetime2](0) NULL,
	[AGE] [bigint] NULL,
	[DOB_YYYY] [bigint] NULL,
	[IS_DCSED] [nchar](1) NULL,
	[DOB_MM] [bigint] NULL,
	[DOB_DD] [bigint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ent_C_PRTY_IND_DTL_aucm]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_ent_C_PRTY_IND_DTL_aucm] ON [dbo].[ent_C_PRTY_IND_DTL_aucm]
(
	[PRTY_FK] ASC
)
INCLUDE([TITLE],[FRST_NM],[MID_NM],[LST_NM],[GNDR],[MARITL_STS],[DOB],[IS_DCSED]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
