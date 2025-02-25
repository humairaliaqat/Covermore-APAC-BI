USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_SALFLDG_reco]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_SALFLDG_reco](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessUnit] [varchar](50) NULL,
	[ScenarioCode] [varchar](50) NULL,
	[ACCNT_CODE] [varchar](50) NULL,
	[PERIOD] [int] NULL,
	[TRANS_DATETIME] [datetime] NULL,
	[JRNAL_NO] [int] NULL,
	[JRNAL_LINE] [int] NULL,
	[AMOUNT] [numeric](18, 3) NULL,
	[D_C] [varchar](50) NULL,
	[ALLOCATION] [varchar](50) NULL,
	[JRNAL_TYPE] [varchar](50) NULL,
	[JRNAL_SRCE] [varchar](50) NULL,
	[TREFERENCE] [varchar](50) NULL,
	[DESCRIPTN] [varchar](50) NULL,
	[ENTRY_DATETIME] [datetime] NULL,
	[ENTRY_PRD] [int] NULL,
	[DUE_DATETIME] [datetime] NULL,
	[ALLOC_REF] [int] NULL,
	[ALLOC_DATETIME] [datetime] NULL,
	[ALLOC_PERIOD] [int] NULL,
	[ASSET_IND] [varchar](50) NULL,
	[ASSET_CODE] [varchar](50) NULL,
	[ASSET_SUB] [varchar](50) NULL,
	[CONV_CODE] [varchar](50) NULL,
	[CONV_RATE] [numeric](18, 9) NULL,
	[OTHER_AMT] [numeric](18, 3) NULL,
	[OTHER_DP] [varchar](50) NULL,
	[CLEARDOWN] [varchar](50) NULL,
	[REVERSAL] [varchar](50) NULL,
	[LOSS_GAIN] [varchar](50) NULL,
	[ROUGH_FLAG] [varchar](50) NULL,
	[IN_USE_FLAG] [varchar](50) NULL,
	[ANAL_T0] [varchar](50) NULL,
	[ANAL_T1] [varchar](50) NULL,
	[ANAL_T2] [varchar](50) NULL,
	[ANAL_T3] [varchar](50) NULL,
	[ANAL_T4] [varchar](50) NULL,
	[ANAL_T5] [varchar](50) NULL,
	[ANAL_T6] [varchar](50) NULL,
	[ANAL_T7] [varchar](50) NULL,
	[ANAL_T8] [varchar](50) NULL,
	[ANAL_T9] [varchar](50) NULL,
	[POSTING_DATETIME] [datetime] NULL,
	[ALLOC_IN_PROGRESS] [varchar](50) NULL,
	[HOLD_REF] [int] NULL,
	[HOLD_OP_ID] [varchar](50) NULL,
	[BASE_RATE] [numeric](18, 9) NULL,
	[BASE_OPERATOR] [varchar](50) NULL,
	[CONV_OPERATOR] [varchar](50) NULL,
	[REPORT_RATE] [numeric](18, 9) NULL,
	[REPORT_OPERATOR] [varchar](50) NULL,
	[REPORT_AMT] [numeric](18, 3) NULL,
	[MEMO_AMT] [numeric](18, 5) NULL,
	[EXCLUDE_BAL] [varchar](50) NULL,
	[LE_DETAILS_IND] [varchar](50) NULL,
	[CONSUMED_BDGT_ID] [int] NULL,
	[CV4_CONV_CODE] [varchar](50) NULL,
	[CV4_AMT] [numeric](18, 3) NULL,
	[CV4_CONV_RATE] [numeric](18, 9) NULL,
	[CV4_OPERATOR] [varchar](50) NULL,
	[CV4_DP] [varchar](50) NULL,
	[CV5_CONV_CODE] [varchar](50) NULL,
	[CV5_AMT] [numeric](18, 3) NULL,
	[CV5_CONV_RATE] [numeric](18, 9) NULL,
	[CV5_OPERATOR] [varchar](50) NULL,
	[CV5_DP] [varchar](50) NULL,
	[LINK_REF_1] [varchar](50) NULL,
	[LINK_REF_2] [varchar](50) NULL,
	[LINK_REF_3] [varchar](50) NULL,
	[ALLOCN_CODE] [varchar](50) NULL,
	[ALLOCN_STMNTS] [int] NULL,
	[OPR_CODE] [varchar](50) NULL,
	[SPLIT_ORIG_LINE] [int] NULL,
	[VAL_DATETIME] [datetime] NULL,
	[SIGNING_DETAILS] [varchar](50) NULL,
	[INSTLMT_DATETIME] [datetime] NULL,
	[PRINCIPAL_REQD] [int] NULL,
	[BINDER_STATUS] [varchar](50) NULL,
	[AGREED_STATUS] [int] NULL,
	[SPLIT_LINK_REF] [varchar](50) NULL,
	[PSTG_REF] [varchar](50) NULL,
	[TRUE_RATED] [int] NULL,
	[HOLD_DATETIME] [datetime] NULL,
	[HOLD_TEXT] [varchar](50) NULL,
	[INSTLMT_NUM] [int] NULL,
	[SUPPLMNTRY_EXTSN] [int] NULL,
	[APRVLS_EXTSN] [int] NULL,
	[REVAL_LINK_REF] [int] NULL,
	[SAVED_SET_NUM] [numeric](18, 0) NULL,
	[AUTHORISTN_SET_REF] [int] NULL,
	[PYMT_AUTHORISTN_SET_REF] [int] NULL,
	[MAN_PAY_OVER] [int] NULL,
	[PYMT_STAMP] [varchar](50) NULL,
	[AUTHORISTN_IN_PROGRESS] [int] NULL,
	[SPLIT_IN_PROGRESS] [int] NULL,
	[VCHR_NUM] [varchar](50) NULL,
	[JNL_CLASS_CODE] [varchar](50) NULL,
	[ORIGINATOR_ID] [varchar](50) NULL,
	[ORIGINATED_DATETIME] [datetime] NULL,
	[LAST_CHANGE_USER_ID] [varchar](50) NULL,
	[LAST_CHANGE_DATETIME] [datetime] NULL,
	[AFTER_PSTG_ID] [varchar](50) NULL,
	[AFTER_PSTG_DATETIME] [datetime] NULL,
	[POSTER_ID] [varchar](50) NULL,
	[ALLOC_ID] [varchar](50) NULL,
	[JNL_REVERSAL_TYPE] [int] NULL
) ON [PRIMARY]
GO
