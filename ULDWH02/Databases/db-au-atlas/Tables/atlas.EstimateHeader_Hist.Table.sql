USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[EstimateHeader_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[EstimateHeader_Hist](
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
	[BenefitCategory_c] [nvarchar](50) NULL,
	[BenefitShell_c] [varchar](25) NULL,
	[BenefitSubCategory_c] [varchar](50) NULL,
	[Case_c] [varchar](25) NULL,
	[LastActivityDate] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[TotalEstimate_c] [varchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_EstimateHeader_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_EstimateHeader_Hist] ON [atlas].[EstimateHeader_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
