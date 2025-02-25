USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[PolicyShell_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[PolicyShell_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[BinNumber_c] [varchar](50) NULL,
	[Brand_c] [varchar](255) NULL,
	[ContactUsEmail_c] [varchar](50) NULL,
	[DirectPhoneNumber_c] [varchar](25) NULL,
	[FromAllOtherCountriesPhone_c] [varchar](25) NULL,
	[FromAustraliaPhone_c] [varchar](25) NULL,
	[FromCanadaPhone_c] [varchar](25) NULL,
	[FromNewZealandPhone_c] [varchar](25) NULL,
	[FromUKPhone_c] [varchar](25) NULL,
	[FromUSAPhone_c] [varchar](25) NULL,
	[MembershipNumber_c] [varchar](255) NULL,
	[Name] [varchar](80) NULL,
	[NewAssistanceProvider_c] [varchar](255) NULL,
	[OwnerId] [varchar](50) NULL,
	[PlanType_c] [varchar](255) NULL,
	[PolicyEndDate_c] [date] NULL,
	[PolicyStartDate_c] [date] NULL,
	[PolicyType_c] [varchar](255) NULL,
	[Program_c] [varchar](25) NULL,
	[TollFreeNumber_c] [varchar](25) NULL,
	[Underwriter_c] [varchar](50) NULL,
	[UWGroup_c] [varchar](50) NULL,
	[UWRegion_c] [nvarchar](1000) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SystemModstamp] [datetime] NULL,
	[AnswerQuestionID_c] [varchar](255) NULL,
	[AnswerQuestionValue_c] [varchar](255) NULL,
	[ProductCode_c] [varchar](30) NULL,
	[PolicyLimit_c] [money] NULL,
	[OrganisationCode_c] [varchar](50) NULL,
	[PolicyChannel_c] [numeric](3, 0) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_PolicyShell_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_PolicyShell_Hist] ON [atlas].[PolicyShell_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
