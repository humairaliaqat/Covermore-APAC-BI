USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Policy]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Policy](
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
	[BinNumber_c] [varchar](50) NULL,
	[BreachType_c] [nvarchar](50) NULL,
	[CardholderDOB_c] [datetime] NULL,
	[CardholderPostalCode_c] [varchar](80) NULL,
	[CClast4digits_c] [varchar](50) NULL,
	[ClassCode_c] [nvarchar](50) NULL,
	[DirectPhoneNumber_c] [nvarchar](25) NULL,
	[EMCApprovalNumber_c] [varchar](255) NULL,
	[Excess_c] [money] NULL,
	[InceptionDate_c] [datetime] NULL,
	[Integration_c] [varchar](50) NULL,
	[Issuer_c] [varchar](255) NULL,
	[MembershipNumber_c] [varchar](255) NULL,
	[Name] [varchar](80) NULL,
	[NewAssistanceProvider_c] [varchar](255) NULL,
	[PlanType_c] [varchar](50) NULL,
	[PolicyBreached_c] [bit] NULL,
	[PolicyChannel_c] [varchar](255) NULL,
	[PolicyEndDate_c] [datetime] NULL,
	[PolicyIssueDate_c] [datetime] NULL,
	[PolicyLimit_c] [money] NULL,
	[PolicyNumber_c] [varchar](255) NULL,
	[PolicyReference_c] [varchar](50) NULL,
	[PolicyRegion_c] [varchar](255) NULL,
	[PolicyShell_c] [varchar](25) NULL,
	[PolicySource_c] [varchar](255) NULL,
	[PolicyStartDate_c] [datetime] NULL,
	[PolicyStatus_c] [nvarchar](50) NULL,
	[PolicyType_c] [varchar](255) NULL,
	[PrimaryCardholder_c] [varchar](80) NULL,
	[ProductCode_c] [varchar](255) NULL,
	[ProductName_c] [varchar](255) NULL,
	[ProgramType_c] [varchar](50) NULL,
	[Program_c] [varchar](25) NULL,
	[SecondaryCCfirst6digits_c] [varchar](50) NULL,
	[SecondaryCClast4digits__c] [varchar](50) NULL,
	[TollFreeNumber_c] [nvarchar](50) NULL,
	[Underwriter_c] [varchar](25) NULL,
	[UWGroup_c] [varchar](50) NULL,
	[UW_Region_c] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Policy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[Policy_Hist])
)
GO
ALTER TABLE [atlas].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Policyshell] FOREIGN KEY([PolicyShell_c])
REFERENCES [atlas].[PolicyShell] ([Id])
GO
ALTER TABLE [atlas].[Policy] CHECK CONSTRAINT [FK_Policy_Policyshell]
GO
