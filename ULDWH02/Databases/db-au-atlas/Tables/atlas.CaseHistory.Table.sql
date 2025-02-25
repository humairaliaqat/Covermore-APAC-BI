USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[CaseHistory]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[CaseHistory](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedById] [varchar](25) NULL,
	[CreatedDate] [datetime] NULL,
	[CaseId] [varchar](25) NULL,
	[Field] [nvarchar](255) NULL,
	[NewValue] [varchar](255) NULL,
	[OldValue] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_CaseHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[CaseHistory_Hist])
)
GO
ALTER TABLE [atlas].[CaseHistory]  WITH CHECK ADD  CONSTRAINT [FK_CaseHistory_User] FOREIGN KEY([CreatedById])
REFERENCES [atlas].[User] ([Id])
GO
ALTER TABLE [atlas].[CaseHistory] CHECK CONSTRAINT [FK_CaseHistory_User]
GO
