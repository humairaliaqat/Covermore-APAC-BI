USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ClinicalAdmissions_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ClinicalAdmissions_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](25) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Account_c] [varchar](25) NULL,
	[AdditionalInformation_c] [varchar](255) NULL,
	[AdmissionTreatmentDate_c] [date] NULL,
	[AppointmentDateTime_c] [datetime] NULL,
	[BillingFaxEmail_c] [varchar](100) NULL,
	[BillingPhone_c] [varchar](100) NULL,
	[Case_c] [varchar](25) NULL,
	[DischargeDateCheck_c] [bit] NULL,
	[DischargeDate_c] [date] NULL,
	[FollowUpAppointmentNeeded_c] [bit] NULL,
	[GP_c] [varchar](25) NULL,
	[MedicalRecordsFaxEmail_c] [varchar](255) NULL,
	[MedicalRecordsPhone_c] [varchar](100) NULL,
	[Name] [varchar](255) NULL,
	[NursingPhone_c] [varchar](100) NULL,
	[NursingStationFaxEmail_c] [varchar](255) NULL,
	[PatientAccountNumber_c] [varchar](255) NULL,
	[Phone_c] [varchar](255) NULL,
	[PhysicianPhone_c] [varchar](100) NULL,
	[Physician_c] [varchar](255) NULL,
	[Provider_c] [varchar](25) NULL,
	[RecordTypeId] [varchar](25) NULL,
	[Referral__c] [bit] NULL,
	[RoomBedNo_c] [varchar](255) NULL,
	[Speciality_c] [varchar](255) NULL,
	[TreatmentProvider_c] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
