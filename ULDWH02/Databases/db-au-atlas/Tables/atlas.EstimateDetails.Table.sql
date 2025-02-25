USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[EstimateDetails]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[EstimateDetails](
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
	[Amount_c] [money] NULL,
	[ApprovalSoughtDetails_c] [varchar](255) NULL,
	[BenefitCategory_c] [nvarchar](50) NULL,
	[BenefitSubCategory_c] [nvarchar](100) NULL,
	[Estimate_c] [varchar](25) NULL,
	[LastActivityDate] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[Notes_c] [varchar](255) NULL,
	[Invoice_c] [varchar](25) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_EstimateDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[EstimateDetails_Hist])
)
GO
ALTER TABLE [atlas].[EstimateDetails]  WITH CHECK ADD  CONSTRAINT [FK_EstimateDetails] FOREIGN KEY([Estimate_c])
REFERENCES [atlas].[EstimateHeader] ([Id])
GO
ALTER TABLE [atlas].[EstimateDetails] CHECK CONSTRAINT [FK_EstimateDetails]
GO
ALTER TABLE [atlas].[EstimateDetails]  WITH CHECK ADD  CONSTRAINT [FK_EstimateDetails_Invoice] FOREIGN KEY([Invoice_c])
REFERENCES [atlas].[Invoice] ([Id])
GO
ALTER TABLE [atlas].[EstimateDetails] CHECK CONSTRAINT [FK_EstimateDetails_Invoice]
GO
