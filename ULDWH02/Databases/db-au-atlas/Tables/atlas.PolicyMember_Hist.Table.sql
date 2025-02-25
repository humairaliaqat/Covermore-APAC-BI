USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[PolicyMember_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[PolicyMember_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [varchar](50) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Account_c] [varchar](25) NULL,
	[Address1_c] [varchar](255) NULL,
	[Address2_c] [varchar](255) NULL,
	[Benefit_c] [varchar](8000) NULL,
	[City_c] [varchar](255) NULL,
	[Country_c] [varchar](255) NULL,
	[DateOfBirth_c] [varchar](50) NULL,
	[Email_c] [nvarchar](255) NULL,
	[EMCAssessmentDate_c] [datetime] NULL,
	[EMCAssessmentNumber_c] [varchar](255) NULL,
	[EMCStatus_c] [nvarchar](50) NULL,
	[FirstName_c] [varchar](255) NULL,
	[Integration_c] [bit] NULL,
	[IsAgedAssessment_c] [bit] NULL,
	[IsAnnualTrip_c] [bit] NULL,
	[IsPrimaryTraveler_c] [bit] NULL,
	[IsWinterSport_c] [bit] NULL,
	[LastName_c] [varchar](255) NULL,
	[MedicalRiskScore_c] [numeric](18, 0) NULL,
	[Name] [nvarchar](50) NULL,
	[OverallScore_c] [numeric](17, 1) NULL,
	[Phone_c] [nvarchar](50) NULL,
	[Policy_c] [varchar](25) NULL,
	[PostalCode_c] [varchar](25) NULL,
	[State_c] [varchar](255) NULL,
	[Status_c] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_PolicyMember_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_PolicyMember_Hist] ON [atlas].[PolicyMember_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
