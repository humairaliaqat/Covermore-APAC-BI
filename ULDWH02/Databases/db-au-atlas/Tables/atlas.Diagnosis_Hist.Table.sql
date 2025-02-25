USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Diagnosis_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Diagnosis_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[Case_c] [varchar](25) NULL,
	[Name] [nvarchar](50) NULL,
	[ICDCode_c] [varchar](50) NULL,
	[Primary_c] [bit] NULL,
	[Secondary_c] [bit] NULL,
	[ICDDescription_c] [varchar](100) NULL,
	[ICDVersion_c] [varchar](100) NULL,
	[Provisional_c] [bit] NULL,
	[Description_c] [varchar](255) NULL,
	[Symptoms_c] [varchar](255) NULL,
	[Confirmed_Diagnosis_c] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SystemModstamp] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Diagnostics_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_Diagnostics_Hist] ON [atlas].[Diagnosis_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
