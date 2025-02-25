USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[EMC_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[EMC_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Assessment_c] [varchar](8000) NULL,
	[ConditionId__c] [varchar](255) NULL,
	[EMCStatus_c] [nvarchar](50) NULL,
	[GroupId_c] [varchar](255) NULL,
	[GroupScore_c] [numeric](17, 1) NULL,
	[Integration__c] [bit] NULL,
	[IsCovered__c] [bit] NULL,
	[IsExcluded__c] [bit] NULL,
	[Name] [varchar](80) NULL,
	[PolicyMember_c] [varchar](25) NULL,
	[Score__c] [numeric](17, 1) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_EMC_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_EMC_Hist] ON [atlas].[EMC_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
