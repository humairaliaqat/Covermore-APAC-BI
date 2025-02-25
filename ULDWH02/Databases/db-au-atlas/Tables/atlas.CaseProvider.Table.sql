USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[CaseProvider]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[CaseProvider](
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
	[Case_c] [varchar](25) NULL,
	[Comments_c] [varchar](8000) NULL,
	[Contact_c] [varchar](25) NULL,
	[Name] [varchar](80) NULL,
	[ProviderEmail_c] [nvarchar](50) NULL,
	[Provider_c] [varchar](25) NULL,
	[Role_c] [nvarchar](50) NULL,
	[Status_c] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_CaseProvider] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[CaseProvider_Hist])
)
GO
ALTER TABLE [atlas].[CaseProvider]  WITH CHECK ADD  CONSTRAINT [FK_CaseProvider_Account] FOREIGN KEY([Provider_c])
REFERENCES [atlas].[Account] ([Id])
GO
ALTER TABLE [atlas].[CaseProvider] CHECK CONSTRAINT [FK_CaseProvider_Account]
GO
ALTER TABLE [atlas].[CaseProvider]  WITH CHECK ADD  CONSTRAINT [FK_CaseProvider_Case] FOREIGN KEY([Case_c])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[CaseProvider] CHECK CONSTRAINT [FK_CaseProvider_Case]
GO
