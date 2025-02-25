USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ent_C_PARTY_PRODUCT_TXN_aucm]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ent_C_PARTY_PRODUCT_TXN_aucm](
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
	[PRTY_ROLE] [nvarchar](20) NULL,
	[PROD_TYP] [nvarchar](25) NULL,
	[PROD_REF_NO] [nvarchar](300) NULL,
	[DOMAIN_CD] [nvarchar](2) NULL,
	[DOMAIN_NM] [nvarchar](20) NULL,
	[POLICY_KEY] [nvarchar](50) NULL,
	[TXN_STATUS] [nvarchar](10) NULL,
	[ACCOUNT_HASH] [nvarchar](255) NULL
) ON [PRIMARY]
GO
