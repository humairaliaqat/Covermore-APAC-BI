USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Risk]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Risk](
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
	[Case_C] [varchar](25) NULL,
	[Name] [varchar](80) NULL,
	[OwnerId] [varchar](25) NULL,
	[QuestionnaireName_c] [varchar](255) NULL,
	[Status_c] [nvarchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Risk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[Risk_Hist])
)
GO
ALTER TABLE [atlas].[Risk]  WITH NOCHECK ADD  CONSTRAINT [FK_Risk_Case] FOREIGN KEY([Case_C])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[Risk] NOCHECK CONSTRAINT [FK_Risk_Case]
GO
