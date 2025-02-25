USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[EstimateHeader]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[EstimateHeader](
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
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_EstimateHeader] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[EstimateHeader_Hist])
)
GO
ALTER TABLE [atlas].[EstimateHeader]  WITH CHECK ADD  CONSTRAINT [FK_EstimateHeader] FOREIGN KEY([Case_c])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[EstimateHeader] CHECK CONSTRAINT [FK_EstimateHeader]
GO
