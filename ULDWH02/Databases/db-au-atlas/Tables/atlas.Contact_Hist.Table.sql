USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Contact_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Contact_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[AccountId] [varchar](25) NULL,
	[RecordTypeId] [varchar](20) NULL,
	[Salutation] [varchar](40) NULL,
	[FirstName] [varchar](40) NULL,
	[MiddleName] [varchar](40) NULL,
	[LastName] [varchar](80) NULL,
	[Birthdate] [datetime] NULL,
	[Vulnerable_c] [bit] NULL,
	[Deceased_c] [bit] NULL,
	[DeathDate_c] [varchar](50) NULL,
	[PotentialIssue_c] [bit] NULL,
	[Defaulter_c] [bit] NULL,
	[PreferredLanguage_c] [nvarchar](255) NULL,
	[Gender_c] [nvarchar](10) NULL,
	[Religion_c] [nvarchar](25) NULL,
	[OtherReligion_c] [varchar](255) NULL,
	[ReligiousAndCulturalConsiderations_c] [varchar](255) NULL,
	[Marital_Status_c] [nvarchar](25) NULL,
	[NoOfChildren_c] [numeric](18, 0) NULL,
	[AssistantName] [varchar](40) NULL,
	[AssistantPhone] [varchar](25) NULL,
	[OwnerId] [varchar](20) NULL,
	[WTP_Contact_Type_c] [nvarchar](50) NULL,
	[WTP_Contact_Type_Other_c] [varchar](80) NULL,
	[Country_Dialing_Code_c] [nvarchar](50) NULL,
	[Create_Portal_User_c] [bit] NULL,
	[Department] [varchar](80) NULL,
	[Description] [varchar](8000) NULL,
	[DoNotCall] [bit] NULL,
	[Email] [varchar](255) NULL,
	[HasOptedOutOfEmail] [bit] NULL,
	[Fax] [varchar](25) NULL,
	[HasOptedOutOfFax] [bit] NULL,
	[HomePhone] [varchar](25) NULL,
	[IndividualId] [varchar](50) NULL,
	[MobilePhone] [varchar](25) NULL,
	[Other_Phone] [varchar](25) NULL,
	[Phone] [varchar](25) NULL,
	[ReportsToId] [varchar](50) NULL,
	[Title] [varchar](128) NULL,
	[FrequentFlyerNumber_c] [varchar](255) NULL,
	[Airline_c] [varchar](255) NULL,
	[PassportNumber_c] [varchar](80) NULL,
	[PotentialIssueReason_c] [varchar](8000) NULL,
	[Sanctioned_c] [bit] NULL,
	[ReasonwhySanctioned_c] [varchar](255) NULL,
	[MailingStreet] [varchar](255) NULL,
	[MailingCity] [varchar](40) NULL,
	[MailingState] [varchar](80) NULL,
	[MailingPostalCode] [varchar](20) NULL,
	[MailingCountry] [varchar](80) NULL,
	[DeveloperName] [varchar](255) NULL,
	[MasterRecordId] [varchar](25) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SystemModstamp] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Contact_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_Contact_Hist] ON [atlas].[Contact_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
