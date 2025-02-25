USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[RiskDetail]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[RiskDetail](
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
	[AdditionalInformation_c] [varchar](255) NULL,
	[Name] [varchar](80) NULL,
	[QuestionCategory_c] [varchar](255) NULL,
	[Question_c] [varchar](255) NULL,
	[ResponseScore_c] [numeric](18, 0) NULL,
	[ResponseType_c] [nvarchar](50) NULL,
	[Response_c] [varchar](255) NULL,
	[Risk_c] [varchar](25) NULL,
	[Score_c] [numeric](18, 0) NULL,
	[ValidValues_c] [varchar](8000) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_RiskDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[RiskDetail_Hist])
)
GO
ALTER TABLE [atlas].[RiskDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_RiskDetail_Risk] FOREIGN KEY([Risk_c])
REFERENCES [atlas].[Risk] ([Id])
GO
ALTER TABLE [atlas].[RiskDetail] NOCHECK CONSTRAINT [FK_RiskDetail_Risk]
GO
