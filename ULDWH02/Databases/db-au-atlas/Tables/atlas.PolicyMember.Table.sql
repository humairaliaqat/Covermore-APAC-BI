USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[PolicyMember]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[PolicyMember](
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
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_STG_Policymember] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[PolicyMember_Hist])
)
GO
ALTER TABLE [atlas].[PolicyMember]  WITH NOCHECK ADD  CONSTRAINT [FK_STG_PolicyMember] FOREIGN KEY([Policy_c])
REFERENCES [atlas].[Policy] ([Id])
GO
ALTER TABLE [atlas].[PolicyMember] NOCHECK CONSTRAINT [FK_STG_PolicyMember]
GO
