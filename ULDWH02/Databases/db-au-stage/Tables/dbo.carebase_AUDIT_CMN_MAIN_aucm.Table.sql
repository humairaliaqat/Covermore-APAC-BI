USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_AUDIT_CMN_MAIN_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_AUDIT_CMN_MAIN_aucm](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_ACTION] [varchar](10) NULL,
	[CASE_NO] [varchar](14) NOT NULL,
	[CLI_CODE] [varchar](2) NULL,
	[POL_CODE] [varchar](2) NULL,
	[OPEN_DATE] [datetime] NULL,
	[AC] [varchar](30) NULL,
	[STATUS] [varchar](1) NULL,
	[POLICY_NO] [nvarchar](25) NULL,
	[POLICYNO2] [varchar](25) NULL,
	[ISSUED] [date] NULL,
	[ISSUED2] [date] NULL,
	[EXPIRES] [date] NULL,
	[EXPIRES2] [date] NULL,
	[DATE_VER1] [date] NULL,
	[DATE_VER2] [date] NULL,
	[VER_BY1] [varchar](10) NULL,
	[VER_BY2] [varchar](10) NULL,
	[POL_AC1] [varchar](30) NULL,
	[POL_AC2] [varchar](30) NULL,
	[POL_REF] [varchar](20) NULL,
	[CASE_REF] [varchar](20) NULL,
	[TYPE_POL] [varchar](23) NULL,
	[TYPE_POL2] [varchar](23) NULL,
	[FAM_SING] [varchar](15) NULL,
	[FAM_SING2] [varchar](15) NULL,
	[POL_PLAN] [varchar](15) NULL,
	[POL_PLAN2] [varchar](15) NULL,
	[DEP_DATE] [date] NULL,
	[DEP_DATE2] [date] NULL,
	[MEMBER_NO] [varchar](25) NULL,
	[REGO] [varchar](10) NULL,
	[NAME_INS1] [varchar](20) NULL,
	[NAME_INS2] [varchar](20) NULL,
	[LOAN_AC1] [varchar](20) NULL,
	[LOAN_AC2] [varchar](20) NULL,
	[CLAIM_NUM] [nvarchar](40) NULL,
	[SURNAME] [nvarchar](100) NULL,
	[FIRST] [nvarchar](100) NULL,
	[SEX] [varchar](1) NULL,
	[LOC_DESC] [nvarchar](200) NULL,
	[CNTRY_CODE] [varchar](3) NULL,
	[PROB_TYPE] [varchar](1) NULL,
	[PROB_CODE] [varchar](3) NULL,
	[PROB_DESC] [varchar](50) NULL,
	[TYPE] [varchar](1) NULL,
	[CLOSED_BY] [varchar](30) NULL,
	[CASE_CODE] [varchar](4) NULL,
	[CLOSEPROB] [varchar](3) NULL,
	[CLOSE_DATE] [datetime] NULL,
	[CHARGECODE] [varchar](4) NULL,
	[CURRENT_AC] [varchar](30) NULL,
	[CMS_CNTR] [int] NULL,
	[INCOMPLETE] [varchar](1) NULL,
	[PAPERFILE] [varchar](1) NULL,
	[PROTNUM] [varchar](4) NULL,
	[CMNUM] [varchar](3) NULL,
	[OVERWRITE] [varchar](1) NULL,
	[QUESTIONS] [varchar](1) NULL,
	[QANSWERED] [varchar](1) NULL,
	[MBFSENT] [varchar](1) NULL,
	[LANGUAGE] [varchar](3) NULL,
	[CREATED_DT] [datetime] NULL,
	[NEXT_ACTN] [datetime] NULL,
	[REGO2] [varchar](10) NULL,
	[DELETED] [varchar](1) NULL,
	[TIMEINCASE] [numeric](9, 3) NULL,
	[CRORIGIN_ID] [float] NULL,
	[INCIDENT_TYPE] [nvarchar](60) NULL,
	[CASE_DESC] [varchar](30) NULL,
	[LOC_ID] [int] NULL,
	[CNTRY_ID] [int] NULL,
	[POL_EXCESS] [int] NULL,
	[LINKCASE_NO] [varchar](14) NULL,
	[DISORDER_TYPE] [varchar](2) NULL,
	[DISORDER_SUBTYPE] [varchar](2) NULL,
	[TOT_EST] [int] NULL,
	[CM_PRODCODE] [varchar](3) NULL,
	[CASE_DESCRIPT] [varchar](4000) NULL,
	[DX_CAT_ID] [int] NULL,
	[MEDICAL_SURGICAL] [varchar](1) NULL,
	[RESEARCH_SPECIFIC] [varchar](100) NULL,
	[DISASTER_ID] [int] NULL,
	[EncryptDOB] [varbinary](100) NULL,
	[CAT_CODE] [nvarchar](50) NULL,
	[UWCOVERSTATUS_ID] [int] NULL,
	[RISKREASON_ID] [int] NULL,
	[RISKLEVEL_ID] [int] NULL,
	[CASETYPE_ID] [int] NULL,
	[INCIDENTTYPE_ID] [int] NULL,
	[CATCODE_ID] [int] NULL,
	[CultureCode] [nvarchar](10) NULL,
	[HasReviewCheck] [bit] NULL,
	[HasReviewCompleted] [bit] NULL,
	[MedicalCareSort] [bit] NULL,
	[CustomerHospitalised] [bit] NULL,
	[MedicalSteerageOccured] [bit] NULL,
	[Case_Fee] [money] NULL
) ON [PRIMARY]
GO
