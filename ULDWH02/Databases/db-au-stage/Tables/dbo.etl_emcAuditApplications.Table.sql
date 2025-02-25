USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_emcAuditApplications]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_emcAuditApplications](
	[CountryKey] [varchar](2) NULL,
	[ApplicationKey] [varchar](15) NULL,
	[AuditApplicationKey] [varchar](15) NULL,
	[CompanyKey] [varchar](11) NULL,
	[ApplicationID] [int] NOT NULL,
	[AuditRecordID] [int] NOT NULL,
	[AuditDate] [datetime] NULL,
	[AuditUserLogin] [varchar](255) NULL,
	[AuditUser] [varchar](50) NULL,
	[AuditAction] [varchar](10) NULL,
	[ApplicationType] [varchar](25) NULL,
	[AgencyCode] [varchar](7) NULL,
	[AssessorID] [smallint] NULL,
	[CreatorID] [int] NULL,
	[Priority] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[ReceiveDate] [datetime] NULL,
	[AssessedDate] [datetime] NULL,
	[IsEndorsementSigned] [bit] NULL,
	[EndorsementDate] [datetime] NULL,
	[ApplicationStatus] [varchar](22) NULL,
	[ApprovalStatus] [varchar](15) NULL,
	[AgeApprovalStatus] [varchar](12) NOT NULL,
	[PlanCode] [nvarchar](50) NULL,
	[ProductCode] [varchar](3) NULL,
	[ProductType] [varchar](100) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[TripDuration] [int] NULL,
	[Destination] [nvarchar](max) NULL,
	[TravellerCount] [tinyint] NULL,
	[ValuePerTraveller] [money] NULL,
	[TripType] [varchar](20) NULL,
	[PolicyNo] [varchar](13) NULL,
	[OtherInsurer] [varchar](50) NULL,
	[InputType] [varchar](10) NULL,
	[FileLocation] [varchar](50) NULL,
	[FileLocationDate] [datetime] NULL,
	[ClaimNo] [int] NULL,
	[ClaimDate] [datetime] NULL,
	[IsClaimRelatedToEMC] [bit] NULL,
	[IsDeclarationSigned] [bit] NULL,
	[IsAnnualBusinessPlan] [bit] NULL,
	[IsApplyingForEMCCover] [bit] NULL,
	[IsApplyingForCMCover] [bit] NULL,
	[HasAgeDestinationDuration] [bit] NULL,
	[IsDutyOfDisclosure] [bit] NULL,
	[IsCruise] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
